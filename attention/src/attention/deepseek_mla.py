"""DeepSeek-V2 Multi-Head Latent Attention (MLA).

Reference: DeepSeek-V2 paper (arXiv:2405.04434), HF impl
`transformers.models.deepseek_v2.modeling_deepseek_v2.DeepseekV2Attention`.

What makes MLA different from MHA/MQA/GQA:

1. **Low-rank latent compression on the KV side.**
   K and V are not projected directly from `hidden`. Instead:
       hidden  --W^DKV-->  c_kv     (kv_lora_rank, e.g. 512)
       c_kv    --W^UK -->  K_nope   (per-head, qk_nope_head_dim)
       c_kv    --W^UV -->  V        (per-head, v_head_dim)
   The KV cache stores `c_kv` (much smaller than full K + V), which is
   the bandwidth-saving win at decode time.

2. **Decoupled RoPE.**
   RoPE doesn't commute with the latent compression (rotating K_nope
   after decompressing it would force the cache to store the rotated
   form, which depends on position). MLA's solution: compute a separate
   single-headed rope-only key channel `K_R` directly from `hidden`,
   apply RoPE to that, and concatenate K_R (broadcast across query
   heads) with K_nope to form the full K. Same on the Q side: a portion
   of Q goes through the rope channel, a portion goes through the
   no-rope (latent-compressible) channel.

3. **Q-side low-rank (optional).**
   DeepSeek-V2 also down-then-up-projects Q (q_lora_rank=1536). Saves
   parameters, similar idea. V2-Lite skips this (`q_lora_rank=None`)
   and projects Q directly.

4. **Per-head dim asymmetry.**
   Effective QK head_dim is `qk_nope_head_dim + qk_rope_head_dim`
   (e.g. 128+64 = 192). V head_dim stays at `v_head_dim` (e.g. 128).
   PyTorch's SDPA requires Q.size(-1) == K.size(-1) == V.size(-1), so
   we pad V with zeros to q_head_dim, run SDPA (FlashAttention backend),
   and slice the padded channels off the output. Mathematically
   identical (P @ 0 = 0); costs a constant ~50% extra FLOPs on the
   second matmul, which is far cheaper than the alternative of
   materializing a B×H_q×S×S scores tensor (which would OOM at long S).

Decode path uses **absorbed** attention — the W^UK projection is folded
into Q and the W^UV projection is folded into the output. This means
attention scores are computed in latent space directly against `c_kv`
without ever materializing K or V at decode time. Standard production
trick (vLLM, SGLang); ARCHITECTURE.md explains the math.
"""
from __future__ import annotations

import math
from typing import Optional

import torch
import torch.nn as nn
import torch.nn.functional as F
from safetensors.torch import load_file
from torch.nn.attention import SDPBackend, sdpa_kernel
import flashinfer
from .base import AttentionConfig, AttentionModule


# Same backend pinning the rest of the project uses (see _impl.py).
# Flash first; fall through to memory-efficient if shape isn't eligible.
_MLA_SDPA_BACKENDS = [
    SDPBackend.FLASH_ATTENTION,
    SDPBackend.EFFICIENT_ATTENTION,
    SDPBackend.MATH,
]


# -----------------------------------------------------------------------------
# Small utilities
# -----------------------------------------------------------------------------

class _RMSNorm(nn.Module):
    """RMSNorm matching DeepSeek's variant. Normalizes in fp32 for stability,
    then casts back to the input dtype."""

    def __init__(self, dim: int, eps: float = 1e-6):
        super().__init__()
        self.weight = nn.Parameter(torch.ones(dim))
        self.eps = eps

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        in_dtype = x.dtype
        x32 = x.to(torch.float32)
        var = x32.pow(2).mean(-1, keepdim=True)
        x32 = x32 * torch.rsqrt(var + self.eps)
        return (self.weight * x32).to(in_dtype)


def _build_rope_cache(seq_len: int, rope_dim: int, base: float, device=None):
    """Compute (cos, sin) tables of shape (seq_len, rope_dim).
    Last dim already pre-duplicated for the rotate-half formulation."""
    inv_freq = 1.0 / (base ** (
        torch.arange(0, rope_dim, 2, dtype=torch.float32, device=device) / rope_dim
    ))
    t = torch.arange(seq_len, dtype=torch.float32, device=device)
    freqs = torch.outer(t, inv_freq)            # (S, rope_dim/2)
    emb = torch.cat([freqs, freqs], dim=-1)     # (S, rope_dim)
    return emb.cos(), emb.sin()


def _rotate_half(x: torch.Tensor) -> torch.Tensor:
    """Standard rotate-half: split last dim into halves and swap with sign flip."""
    half = x.shape[-1] // 2
    x1, x2 = x[..., :half], x[..., half:]
    return torch.cat((-x2, x1), dim=-1)


def _apply_rope(x: torch.Tensor, cos: torch.Tensor, sin: torch.Tensor) -> torch.Tensor:
    """x can be (..., rope_dim). cos / sin shapes broadcast with x."""
    return x * cos.to(x.dtype) + _rotate_half(x) * sin.to(x.dtype)


# -----------------------------------------------------------------------------
# DeepseekMLA wrapper
# -----------------------------------------------------------------------------

class DeepseekMLA(AttentionModule):
    """DeepSeek-V2 MLA — single attention layer, prefill + absorbed decode."""

    def __init__(self, cfg: AttentionConfig):
        super().__init__(cfg)
        if cfg.variant != "MLA":
            raise ValueError(f"DeepseekMLA expects variant='MLA', got {cfg.variant!r}")
        for name in ("kv_lora_rank", "qk_nope_head_dim", "qk_rope_head_dim", "v_head_dim"):
            if getattr(cfg, name) is None:
                raise ValueError(f"MLA config missing required field: {name}")

        H = cfg.hidden_size
        self.hidden_size = H
        self.num_heads = cfg.num_attention_heads
        self.q_lora_rank = cfg.q_lora_rank             # may be None (V2-Lite)
        self.kv_lora_rank = cfg.kv_lora_rank
        self.qk_nope_head_dim = cfg.qk_nope_head_dim
        self.qk_rope_head_dim = cfg.qk_rope_head_dim
        self.v_head_dim = cfg.v_head_dim
        self.q_head_dim = self.qk_nope_head_dim + self.qk_rope_head_dim
        self.rope_theta = cfg.rope_theta
        self.max_pos = cfg.max_position_embeddings

        # Q-side projections
        if self.q_lora_rank is not None:
            self.q_a_proj = nn.Linear(H, self.q_lora_rank, bias=False)
            self.q_a_layernorm = _RMSNorm(self.q_lora_rank)
            self.q_b_proj = nn.Linear(self.q_lora_rank, self.num_heads * self.q_head_dim, bias=False)
        else:
            self.q_proj = nn.Linear(H, self.num_heads * self.q_head_dim, bias=False)

        # KV-side projections — combined down (lora_rank + rope_dim), then per-head up.
        # `kv_a_proj_with_mqa` outputs lora_rank + rope_dim; we split the result.
        self.kv_a_proj_with_mqa = nn.Linear(H, self.kv_lora_rank + self.qk_rope_head_dim, bias=False)
        self.kv_a_layernorm = _RMSNorm(self.kv_lora_rank)
        self.kv_b_proj = nn.Linear(
            self.kv_lora_rank,
            self.num_heads * (self.qk_nope_head_dim + self.v_head_dim),
            bias=False,
        )

        # Output projection: per-head V back to hidden
        self.o_proj = nn.Linear(self.num_heads * self.v_head_dim, H, bias=False)

        # RoPE table for the rope-only channels (only qk_rope_head_dim wide)
        cos, sin = _build_rope_cache(self.max_pos, self.qk_rope_head_dim, self.rope_theta)
        self.register_buffer("rope_cos", cos, persistent=False)
        self.register_buffer("rope_sin", sin, persistent=False)

    # -------------------------------------------------------------------------
    # Internal projection helpers
    # -------------------------------------------------------------------------

    def _project_q(self, hidden: torch.Tensor) -> torch.Tensor:
        """hidden (B, S, H) → q (B, S, num_heads, q_head_dim)."""
        if self.q_lora_rank is not None:
            c_q = self.q_a_proj(hidden)
            c_q = self.q_a_layernorm(c_q)
            q = self.q_b_proj(c_q)
        else:
            q = self.q_proj(hidden)
        B, S = hidden.shape[:2]
        return q.view(B, S, self.num_heads, self.q_head_dim)

    def _project_kv_latent(self, hidden: torch.Tensor):
        """hidden → (c_kv, K_R). K_R is single-headed (shape B,S,rope_dim)."""
        kv_a = self.kv_a_proj_with_mqa(hidden)        # (B, S, lora_rank + rope_dim)
        c_kv, k_r = kv_a.split([self.kv_lora_rank, self.qk_rope_head_dim], dim=-1)
        c_kv = self.kv_a_layernorm(c_kv)
        return c_kv, k_r

    def _decompress_kv(self, c_kv: torch.Tensor):
        """c_kv (B, S, lora_rank) → K_nope (B,S,H,nope_dim), V (B,S,H,v_dim)."""
        kv = self.kv_b_proj(c_kv)                     # (B, S, H*(nope+v))
        B, S = c_kv.shape[:2]
        kv = kv.view(B, S, self.num_heads, self.qk_nope_head_dim + self.v_head_dim)
        k_nope, v = kv.split([self.qk_nope_head_dim, self.v_head_dim], dim=-1)
        return k_nope, v

    def _rope_for_positions(self, position_ids: torch.Tensor):
        """Look up cos/sin for the given (B, S) positions, return shape (B, S, rope_dim)."""
        cos = self.rope_cos[position_ids]    # (B, S, rope_dim)
        sin = self.rope_sin[position_ids]
        return cos, sin

    # -------------------------------------------------------------------------
    # Prefill forward — manual attention because Q/K head_dim != V head_dim.
    # -------------------------------------------------------------------------

    def forward(
        self,
        hidden_states: torch.Tensor,
        position_ids: torch.Tensor,
        attention_mask: Optional[torch.Tensor] = None,
    ) -> torch.Tensor:
        B, S, _ = hidden_states.shape
        H_q = self.num_heads
        d_nope = self.qk_nope_head_dim
        d_rope = self.qk_rope_head_dim
        d_v = self.v_head_dim

        # Q
        q = self._project_q(hidden_states)                        # (B, S, H_q, q_head_dim)
        q_nope, q_rope = q.split([d_nope, d_rope], dim=-1)        # (B,S,H_q,d_nope), (B,S,H_q,d_rope)

        # KV (latent + rope-only K)
        c_kv, k_r = self._project_kv_latent(hidden_states)        # (B,S,lora), (B,S,d_rope)
        k_nope, v = self._decompress_kv(c_kv)                     # (B,S,H_q,d_nope), (B,S,H_q,d_v)

        # RoPE on q_rope (per-head) and k_r (single-headed, broadcast next)
        cos, sin = self._rope_for_positions(position_ids)         # (B, S, d_rope)
        # For q_rope we need shape (B, S, 1, d_rope) → broadcast across H_q
        q_rope = _apply_rope(q_rope, cos.unsqueeze(2), sin.unsqueeze(2))
        # k_r is (B, S, d_rope) — apply RoPE before broadcasting
        k_r = _apply_rope(k_r, cos, sin)

        # Form full K by concatenating per-head K_nope with broadcast K_R
        k_r_broadcast = k_r.unsqueeze(2).expand(-1, -1, H_q, -1)  # (B, S, H_q, d_rope)
        k = torch.cat([k_nope, k_r_broadcast], dim=-1)            # (B, S, H_q, q_head_dim)
        q = torch.cat([q_nope, q_rope], dim=-1)                   # (B, S, H_q, q_head_dim)

        scale = 1.0 / math.sqrt(self.q_head_dim)
        is_causal = attention_mask is None


        # 1. Initialize the workspace and wrapper once per layer to avoid allocation overhead
        if not hasattr(self, "_flashinfer_workspace"):
            self._flashinfer_workspace = torch.empty(32 * 1024 * 1024, dtype=torch.uint8, device=q.device)
            self._flashinfer_wrapper = flashinfer.BatchPrefillWithRaggedKVCacheWrapper(
                self._flashinfer_workspace, "NHD"
            )

        # 2. Flatten inputs into Ragged Tensor format (Batch * Seq, Heads, Dim)
        q_flat = q.reshape(B * S, H_q, self.q_head_dim)
        k_flat = k.reshape(B * S, H_q, self.q_head_dim)
        v_flat = v.reshape(B * S, H_q, d_v)

        # 3. Create the indptr (Index Pointer) array for sequence boundaries
        indptr = torch.arange(0, (B + 1) * S, step=S, dtype=torch.int32, device=q.device)

        # 4. Plan the batched execution
        self._flashinfer_wrapper.plan(
            qo_indptr=indptr,
            kv_indptr=indptr,
            num_qo_heads=H_q,
            num_kv_heads=H_q,
            head_dim_qk=self.q_head_dim,
            head_dim_vo=d_v,
            causal=is_causal,
            sm_scale=scale,
            q_data_type=q.dtype  # <--- Add this line
        )

        # 5. Execute the fused kernel
        out_flat = self._flashinfer_wrapper.run(q_flat, k_flat, v_flat)

        # 6. Reshape back to the expected output shape and project
        out = out_flat.view(B, S, H_q * d_v)
        return self.o_proj(out)

    # -------------------------------------------------------------------------
    # Decode: cache c_kv + K_R only, attend in latent space (absorbed).
    # -------------------------------------------------------------------------

    def precompute_kv_into_buffer(
        self,
        hidden_states: torch.Tensor,                    # (B, S, H)
        position_ids: torch.Tensor,                     # (B, S)
        c_kv_cache: torch.Tensor,                       # (B, max_S, lora_rank)
        k_r_cache: torch.Tensor,                        # (B, max_S, rope_dim)
    ) -> int:
        """Pre-fill the latent KV cache with S tokens. Returns new cache_len = S.

        The cache is small (lora_rank + rope_dim per token, e.g. 576-dim total
        for DeepSeek-V2) — this is the storage savings vs full GQA where each
        token costs num_kv_heads * head_dim * 2 bytes. K_R is stored already
        rotated so decode steps don't re-RoPE old positions.
        """
        B, S, _ = hidden_states.shape
        c_kv, k_r = self._project_kv_latent(hidden_states)
        cos, sin = self._rope_for_positions(position_ids)
        k_r = _apply_rope(k_r, cos, sin)
        c_kv_cache[:, :S, :].copy_(c_kv)
        k_r_cache[:, :S, :].copy_(k_r)
        return S

    def forward_decode_inplace(
        self,
        hidden_state: torch.Tensor,                     # (B, 1, H)
        position_ids: torch.Tensor,                     # (B, 1)
        c_kv_cache: torch.Tensor,                       # (B, max_S, lora_rank)
        k_r_cache: torch.Tensor,                        # (B, max_S, rope_dim)
        cache_len: int,
    ) -> tuple[torch.Tensor, int]:
        """Single-token decode using **absorbed** MLA attention.

        Math in latent space (avoids ever materializing full K, V from cache):

            score_nope[b,h,s] = Q_nope[b,h] @ W^UK[h] @ c_kv[b,s]^T
                              = (Q_nope @ W^UK)[b,h] @ c_kv[b,s]^T

            score_rope[b,h,s] = Q_rope[b,h] @ K_R[b,s]^T   (K_R is single-head, broadcast)

            partial[b,h]      = sum_s P[b,h,s] · c_kv[b,s]
            output[b,h]       = partial[b,h] @ W^UV[h]^T

        So all the per-step work touches:
          - c_kv_cache slice (B, cache_len+1, lora_rank)        — what we read
          - W^UK / W^UV (constant tensors, on-chip)
          - Q for this single token (small)

        HBM traffic per step is dominated by the c_kv slice — much smaller
        than reading a full K, V cache would be. This is the MLA win.
        """
        B = hidden_state.shape[0]
        H_q = self.num_heads
        d_nope = self.qk_nope_head_dim
        d_rope = self.qk_rope_head_dim
        d_v = self.v_head_dim
        d_lora = self.kv_lora_rank

        # --- Project Q for this single new token ---
        q = self._project_q(hidden_state)                         # (B, 1, H_q, q_head_dim)
        q_nope, q_rope = q.split([d_nope, d_rope], dim=-1)        # (B, 1, H_q, ·)

        # --- Project KV for this single new token; append to cache ---
        c_kv_new, k_r_new = self._project_kv_latent(hidden_state) # (B, 1, lora), (B, 1, d_rope)

        # RoPE on q_rope and the new k_r row
        cos, sin = self._rope_for_positions(position_ids)         # (B, 1, d_rope)
        q_rope = _apply_rope(q_rope, cos.unsqueeze(2), sin.unsqueeze(2))
        k_r_new = _apply_rope(k_r_new, cos, sin)

        # In-place cache append
        new_len = cache_len + 1
        c_kv_cache[:, cache_len:new_len, :].copy_(c_kv_new)
        k_r_cache[:, cache_len:new_len, :].copy_(k_r_new)

        c_kv_active = c_kv_cache[:, :new_len, :]                  # (B, new_len, lora)
        k_r_active = k_r_cache[:, :new_len, :]                    # (B, new_len, d_rope)

        # --- Absorbed scores ---
        # Split kv_b_proj.weight into per-head W^UK and W^UV blocks.
        # kv_b_proj.weight shape: (H_q*(d_nope+d_v), lora_rank).
        kvb = self.kv_b_proj.weight.view(H_q, d_nope + d_v, d_lora)
        w_uk = kvb[:, :d_nope, :]                                 # (H_q, d_nope, lora)
        w_uv = kvb[:, d_nope:, :]                                 # (H_q, d_v,    lora)

        # Q_nope @ W^UK → Q in latent space, per head. q_nope: (B,1,H_q,d_nope).
        # q_nope_latent[b, q, h, l] = sum_n q_nope[b,q,h,n] * w_uk[h,n,l]
        q_nope_latent = torch.einsum("bqhn,hnl->bqhl", q_nope, w_uk)   # (B, 1, H_q, lora)

        # score_nope[b,h,q,s] = q_nope_latent[b,q,h,:] · c_kv_active[b,s,:]
        score_nope = torch.einsum("bqhl,bsl->bhqs", q_nope_latent, c_kv_active)

        # score_rope[b,h,q,s] = q_rope[b,q,h,:] · k_r_active[b,s,:]   (K_R broadcasts across H_q)
        score_rope = torch.einsum("bqhd,bsd->bhqs", q_rope, k_r_active)

        scale = 1.0 / math.sqrt(self.q_head_dim)
        scores = (score_nope + score_rope) * scale                # (B, H_q, 1, new_len)

        # No causal mask needed — the new query attends to all cached positions
        # (which are by construction in the past).
        probs = F.softmax(scores, dim=-1, dtype=torch.float32).to(scores.dtype)

        # partial = P @ c_kv → (B, H_q, 1, lora)
        partial = torch.einsum("bhqs,bsl->bhql", probs, c_kv_active)

        # out = partial @ W^UV^T → (B, H_q, 1, d_v)
        out = torch.einsum("bhql,hvl->bhqv", partial, w_uv)

        # Reshape and o_proj
        out = out.transpose(1, 2).contiguous().view(B, 1, H_q * d_v)
        out = self.o_proj(out)
        return out, new_len

    # The non-inplace decode helpers (forward_decode, precompute_kv) aren't
    # strictly needed for the inplace decode benchmark path; left as TODO if
    # the cat-mode comparison is ever re-enabled for MLA.

    # -------------------------------------------------------------------------
    # AttentionModule plumbing
    # -------------------------------------------------------------------------

    def random_init(self, dtype: torch.dtype = torch.float16) -> None:
        self.to(dtype=dtype)

    def load_weights(self, path: str) -> None:
        sd = load_file(path)
        i = self.cfg.layer_index
        prefix = f"model.layers.{i}.self_attn."
        # Mapping wrapper-key -> HF state_dict key.
        if self.q_lora_rank is not None:
            remap = {
                "q_a_proj.weight":           f"{prefix}q_a_proj.weight",
                "q_a_layernorm.weight":      f"{prefix}q_a_layernorm.weight",
                "q_b_proj.weight":           f"{prefix}q_b_proj.weight",
            }
        else:
            remap = {"q_proj.weight": f"{prefix}q_proj.weight"}
        remap.update({
            "kv_a_proj_with_mqa.weight": f"{prefix}kv_a_proj_with_mqa.weight",
            "kv_a_layernorm.weight":     f"{prefix}kv_a_layernorm.weight",
            "kv_b_proj.weight":          f"{prefix}kv_b_proj.weight",
            "o_proj.weight":             f"{prefix}o_proj.weight",
        })
        new_sd = {ours: sd[src] for ours, src in remap.items() if src in sd}
        missing = set(remap) - set(new_sd)
        if missing:
            raise RuntimeError(
                f"Missing expected MLA keys in {path}: {sorted(missing)}"
            )
        self.load_state_dict(new_sd, strict=False)
