"""Reference attention implementation parameterized by KV-head count
and positional-encoding strategy.

One implementation handles MHA (kv_heads == q_heads), MQA (kv_heads == 1)
and GQA (1 < kv_heads < q_heads). The only per-variant differences are:

    - projection shapes
    - the positional encoder (RoPE vs. learned absolute vs. ALiBi)

The forward path uses `torch.nn.functional.scaled_dot_product_attention`
with `enable_gqa=True` (PyTorch >= 2.5) so MQA/GQA are dispatched to
their *native* fused kernel instead of materialising a full-sized K/V
via `repeat_interleave`. That's the difference between measuring "GQA as
deployed" vs. "dense attention with extra memory traffic."

SDPA backend selection is pinned via `torch.nn.attention.sdpa_kernel`:

    - CUDA: prefer FLASH_ATTENTION, fall through to EFFICIENT_ATTENTION,
      fall through to MATH. FlashAttention-2 is available on Ada (L40S)
      and Hopper at FP16/BF16.
    - CPU:  Flash is not eligible; falls through to the oneDNN-fused
      EFFICIENT path, or MATH for shapes that oneDNN doesn't accelerate.

The chosen backend for each run is recorded in the JSONL output by the
driver, so a reader can see whether Flash actually fired.
"""
from __future__ import annotations

import math
from typing import Optional

import torch
import torch.nn as nn
import torch.nn.functional as F
from torch.nn.attention import SDPBackend, sdpa_kernel

from .positional import PositionalEncoder, NoOpEncoder


# Preference order used for every SDPA call. On CUDA, Flash fires first;
# on CPU, it's silently skipped because it's ineligible, and the next
# eligible backend is picked. Mutable so the driver can override via
# `set_sdpa_backend("math" | "efficient" | "flash" | "auto")` — useful
# for isolating kernel contributions to measured latency.
_SDPA_BACKEND_ORDER: list[SDPBackend] = [
    SDPBackend.FLASH_ATTENTION,
    SDPBackend.EFFICIENT_ATTENTION,
    SDPBackend.MATH,
]


def set_sdpa_backend(choice: str) -> None:
    """Override the SDPA backend preference used by AttentionImpl.forward.

    Accepts:
      "flash"      -> Flash only, fall through to efficient/math if ineligible
      "efficient"  -> Efficient only, fall through to math
      "math"       -> Force the math backend (slow but portable)
      "auto"       -> Let PyTorch pick — default priority order
    """
    global _SDPA_BACKEND_ORDER
    mapping = {
        "flash":     [SDPBackend.FLASH_ATTENTION, SDPBackend.EFFICIENT_ATTENTION, SDPBackend.MATH],
        "efficient": [SDPBackend.EFFICIENT_ATTENTION, SDPBackend.MATH],
        "math":      [SDPBackend.MATH],
        "auto":      [SDPBackend.FLASH_ATTENTION, SDPBackend.EFFICIENT_ATTENTION, SDPBackend.MATH],
    }
    if choice not in mapping:
        raise ValueError(f"Unknown SDPA backend: {choice}")
    _SDPA_BACKEND_ORDER = mapping[choice]


class AttentionImpl(nn.Module):
    """Generic (M|MQ|GQ)A block — positional encoding + SDPA + output proj."""

    def __init__(
        self,
        hidden_size: int,
        num_q_heads: int,
        num_kv_heads: int,
        head_dim: int,
        positional_encoder: Optional[PositionalEncoder] = None,
        bias_qkv: bool = False,
        bias_o: bool = False,
    ):
        super().__init__()
        if num_q_heads % num_kv_heads != 0:
            raise ValueError(
                f"num_q_heads ({num_q_heads}) must be divisible by "
                f"num_kv_heads ({num_kv_heads}) for GQA/MQA dispatch."
            )
        self.hidden_size = hidden_size
        self.num_q_heads = num_q_heads
        self.num_kv_heads = num_kv_heads
        self.head_dim = head_dim
        self.pe = positional_encoder if positional_encoder is not None else NoOpEncoder()

        q_out = num_q_heads * head_dim
        kv_out = num_kv_heads * head_dim
        self.q_proj = nn.Linear(hidden_size, q_out, bias=bias_qkv)
        self.k_proj = nn.Linear(hidden_size, kv_out, bias=bias_qkv)
        self.v_proj = nn.Linear(hidden_size, kv_out, bias=bias_qkv)
        self.o_proj = nn.Linear(q_out, hidden_size, bias=bias_o)

    def forward(
        self,
        hidden_states: torch.Tensor,
        position_ids: torch.Tensor,
        attention_mask: Optional[torch.Tensor] = None,
    ) -> torch.Tensor:
        B, S, _ = hidden_states.shape
        H_q, H_kv, D = self.num_q_heads, self.num_kv_heads, self.head_dim

        # Hook 1: pre-projection (learned absolute positions add here).
        hidden_states = self.pe.hook_pre_projection(hidden_states, position_ids)

        q = self.q_proj(hidden_states).view(B, S, H_q, D).transpose(1, 2)   # (B, H_q, S, D)
        k = self.k_proj(hidden_states).view(B, S, H_kv, D).transpose(1, 2)  # (B, H_kv, S, D)
        v = self.v_proj(hidden_states).view(B, S, H_kv, D).transpose(1, 2)

        # Hook 2: post-projection (RoPE rotates here).
        q, k = self.pe.hook_qk(q, k, position_ids)

        # Hook 3: attention bias (ALiBi would add here; default no-op).
        attn_mask = self.pe.hook_attn_bias(attention_mask, S, q.device, q.dtype)

        # Native GQA/MQA dispatch. PyTorch >= 2.5 handles the H_q/H_kv
        # broadcast inside the fused kernel, so we never materialise a
        # full-sized K/V in HBM — this is what makes the MQA/GQA memory
        # win real instead of synthetic.
        with sdpa_kernel(_SDPA_BACKEND_ORDER):
            out = F.scaled_dot_product_attention(
                q, k, v,
                attn_mask=attn_mask,
                is_causal=(attn_mask is None),
                scale=1.0 / math.sqrt(D),
                enable_gqa=(H_kv != H_q),
            )
        # (B, H_q, S, D)
        out = out.transpose(1, 2).contiguous().view(B, S, H_q * D)
        return self.o_proj(out)

    # -------------------------------------------------------------------------
    # Fast KV-cache prefill — used by decode benchmarks to populate the cache
    # for an S_init-token prefix in ONE big call instead of iterating
    # forward_decode S_init times. ~80× faster setup at large S_init.
    # -------------------------------------------------------------------------

    def precompute_kv(
        self,
        hidden_states: torch.Tensor,                   # (B, S, H)
        position_ids: torch.Tensor,                    # (B, S)
    ) -> tuple[torch.Tensor, torch.Tensor]:
        """Project hidden_states to K, V (with positional encoding applied)
        and return them shaped (B, H_kv, S, D). Skips Q, skips SDPA, skips
        O-projection. Use to warm a KV cache before a decode loop.
        """
        B, S, _ = hidden_states.shape
        H_q, H_kv, D = self.num_q_heads, self.num_kv_heads, self.head_dim

        # Pre-projection hook (learned absolute positions add here).
        hidden_states = self.pe.hook_pre_projection(hidden_states, position_ids)

        k = self.k_proj(hidden_states).view(B, S, H_kv, D).transpose(1, 2)
        v = self.v_proj(hidden_states).view(B, S, H_kv, D).transpose(1, 2)

        # Apply RoPE (or any post-projection hook) to K. The hook expects a
        # Q tensor too — we feed it a zero Q (its rotated output is discarded).
        # Encoders that don't override hook_qk (e.g. LearnedAbsoluteEncoder)
        # are no-ops at this stage anyway.
        dummy_q = torch.zeros(B, H_q, S, D, device=k.device, dtype=k.dtype)
        _, k = self.pe.hook_qk(dummy_q, k, position_ids)

        return k, v

    # -------------------------------------------------------------------------
    # Pre-allocated KV cache, in-place update — production-style decode path.
    #
    # Avoids the torch.cat allocator fragmentation that plagues the naive
    # decode loop. The caller supplies (k_cache, v_cache) of shape
    # (B, H_kv, max_S, D) along with the current cache_len; we write the new
    # K, V at index cache_len and slice [0:cache_len+1] for SDPA. No tensor
    # allocations grow over the decode trajectory — fixed memory footprint
    # for the whole loop, exactly how vLLM/TensorRT-LLM operate internally.
    # -------------------------------------------------------------------------

    def precompute_kv_into_buffer(
        self,
        hidden_states: torch.Tensor,            # (B, S, H)
        position_ids: torch.Tensor,             # (B, S)
        k_cache: torch.Tensor,                  # (B, H_kv, max_S, D), pre-alloc
        v_cache: torch.Tensor,                  # (B, H_kv, max_S, D), pre-alloc
    ) -> int:
        """Compute K, V for an S-token prefix and write into the first S
        positions of the pre-allocated cache buffer. Returns the new
        cache_len (= S). Mirrors precompute_kv but writes in-place."""
        B, S, _ = hidden_states.shape
        H_q, H_kv, D = self.num_q_heads, self.num_kv_heads, self.head_dim

        hidden_states = self.pe.hook_pre_projection(hidden_states, position_ids)

        k = self.k_proj(hidden_states).view(B, S, H_kv, D).transpose(1, 2)
        v = self.v_proj(hidden_states).view(B, S, H_kv, D).transpose(1, 2)

        dummy_q = torch.zeros(B, H_q, S, D, device=k.device, dtype=k.dtype)
        _, k = self.pe.hook_qk(dummy_q, k, position_ids)

        k_cache[:, :, :S, :].copy_(k)
        v_cache[:, :, :S, :].copy_(v)
        return S

    def forward_decode_inplace(
        self,
        hidden_state: torch.Tensor,             # (B, 1, H)
        position_ids: torch.Tensor,             # (B, 1)
        k_cache: torch.Tensor,                  # (B, H_kv, max_S, D)
        v_cache: torch.Tensor,                  # (B, H_kv, max_S, D)
        cache_len: int,
    ) -> tuple[torch.Tensor, int]:
        """Single-token decode, in-place into pre-allocated cache buffers.

        Args:
            hidden_state : (B, 1, H), the new token's hidden state
            position_ids : (B, 1), absolute position of this token
            k_cache, v_cache : (B, H_kv, max_S, D), pre-allocated, max_S must
                               be ≥ cache_len + 1
            cache_len    : current valid length already in the cache

        Returns:
            output : (B, 1, H)
            new_cache_len : cache_len + 1
        """
        B, S_q, _ = hidden_state.shape
        assert S_q == 1, f"forward_decode_inplace expects S=1, got {S_q}"
        H_q, H_kv, D = self.num_q_heads, self.num_kv_heads, self.head_dim

        # Pre-projection hook (learned-positions models)
        hidden_state = self.pe.hook_pre_projection(hidden_state, position_ids)

        q     = self.q_proj(hidden_state).view(B, 1, H_q,  D).transpose(1, 2)   # (B, H_q, 1, D)
        k_new = self.k_proj(hidden_state).view(B, 1, H_kv, D).transpose(1, 2)   # (B, H_kv, 1, D)
        v_new = self.v_proj(hidden_state).view(B, 1, H_kv, D).transpose(1, 2)

        # RoPE (or other post-projection encoder)
        q, k_new = self.pe.hook_qk(q, k_new, position_ids)

        # In-place write into the pre-allocated cache slot.
        k_cache[:, :, cache_len:cache_len + 1, :].copy_(k_new)
        v_cache[:, :, cache_len:cache_len + 1, :].copy_(v_new)
        new_cache_len = cache_len + 1

        # Slice the live portion of the cache (zero-cost view, no copy).
        k_active = k_cache[:, :, :new_cache_len, :]
        v_active = v_cache[:, :, :new_cache_len, :]

        with sdpa_kernel(_SDPA_BACKEND_ORDER):
            out = F.scaled_dot_product_attention(
                q, k_active, v_active,
                attn_mask=None, is_causal=False,
                scale=1.0 / math.sqrt(D),
                enable_gqa=(H_kv != H_q),
            )
        # (B, H_q, 1, D) -> (B, 1, H_q*D) -> (B, 1, H)
        out = out.transpose(1, 2).contiguous().view(B, 1, H_q * D)
        return self.o_proj(out), new_cache_len

    # -------------------------------------------------------------------------
    # Decode path: process a single new token, append to the KV cache, and
    # attend against the entire (cache + this token). This is the workload
    # that dominates real LLM inference at decode-time and is where the
    # MQA/GQA bandwidth advantage actually manifests.
    # -------------------------------------------------------------------------

    def forward_decode(
        self,
        hidden_state: torch.Tensor,                    # (B, 1, H)
        position_ids: torch.Tensor,                    # (B, 1)  — absolute position of this token
        past_kv: Optional[tuple[torch.Tensor, torch.Tensor]] = None,
    ) -> tuple[torch.Tensor, tuple[torch.Tensor, torch.Tensor]]:
        """Single-token decode forward.

        Args:
            hidden_state : (B, 1, H), the new token's hidden state.
            position_ids : (B, 1), the new token's absolute position in the sequence.
            past_kv      : optional (past_K, past_V) where past_K, past_V have
                           shape (B, H_kv, S_past, D). Pass None for the very
                           first call (no cache yet).

        Returns:
            output : (B, 1, H) — attention output for this token (post O-proj).
            new_kv : (K, V) of shape (B, H_kv, S_past + 1, D), suitable to be
                     fed back as `past_kv` in the next call.
        """
        B, S_q, _ = hidden_state.shape
        assert S_q == 1, f"forward_decode expects a single-token input, got S={S_q}"
        H_q, H_kv, D = self.num_q_heads, self.num_kv_heads, self.head_dim

        # Hook 1: pre-projection (learned absolute positions for StarCoder-style models).
        hidden_state = self.pe.hook_pre_projection(hidden_state, position_ids)

        # Compute Q, K, V for the new token only.
        q     = self.q_proj(hidden_state).view(B, 1, H_q,  D).transpose(1, 2)   # (B, H_q, 1, D)
        k_new = self.k_proj(hidden_state).view(B, 1, H_kv, D).transpose(1, 2)   # (B, H_kv, 1, D)
        v_new = self.v_proj(hidden_state).view(B, 1, H_kv, D).transpose(1, 2)

        # Hook 2: RoPE rotates Q and the new K row using the absolute position.
        q, k_new = self.pe.hook_qk(q, k_new, position_ids)

        # Append the new K, V to the running cache.
        if past_kv is not None:
            past_k, past_v = past_kv
            k = torch.cat([past_k, k_new], dim=2)        # (B, H_kv, S_past+1, D)
            v = torch.cat([past_v, v_new], dim=2)
        else:
            k, v = k_new, v_new                          # first token, no cache yet

        # SDPA over (Q with one row) × (full K, V). No causal mask is needed
        # because the new query trivially sees only past + itself; there is no
        # future to mask out at decode time.
        with sdpa_kernel(_SDPA_BACKEND_ORDER):
            out = F.scaled_dot_product_attention(
                q, k, v,
                attn_mask=None,
                is_causal=False,
                scale=1.0 / math.sqrt(D),
                enable_gqa=(H_kv != H_q),
            )
        # (B, H_q, 1, D) -> (B, 1, H_q*D) -> (B, 1, H)
        out = out.transpose(1, 2).contiguous().view(B, 1, H_q * D)
        return self.o_proj(out), (k, v)
