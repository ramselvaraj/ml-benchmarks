"""Analytic FLOP and byte counting for one attention forward pass.

These are the inputs to a roofline plot. We count FLOPs as multiply-adds
(1 MAC = 2 FLOPs) and bytes as the *minimum* that must move between
DRAM and the compute unit assuming infinite re-use within a tile (so the
QK^T and AV matmuls touch K and V only once each, not S^2 times).

Caller should compare against the platform's peak FLOPs and DRAM
bandwidth to place each (variant, seq_len) point on the roofline.

Two paths are supported:

- **Standard MHA/MQA/GQA** — direct Q, K, V, O projections of shape
  `H × (H_{q|kv} × D)`. This is what `attention_flops_bytes(...)` computes
  by default.
- **MLA (DeepSeek-V2/V3 style)** — low-rank Q (q_a then q_b), combined
  KV-down (`H → kv_lora_rank + qk_rope_head_dim`), KV-up
  (`kv_lora_rank → H_q × (qk_nope_head_dim + v_head_dim)`), and an
  output projection that uses `v_head_dim` not `qk_head_dim`. Pass the
  MLA fields as keyword arguments to dispatch to the MLA-aware path; if
  any are non-None, MLA accounting kicks in.

If the MLA path isn't taken for an MLA model, FLOPs are over-counted by
~3× (full-rank Q, K, V projections at `H_q × qk_head_dim` instead of the
actual low-rank decomposition), which makes utilization read above 100%
and pushes roofline points above the ceiling. So pass the MLA fields.
"""
from __future__ import annotations

from dataclasses import dataclass
from typing import Optional

import torch


@dataclass
class RooflinePoint:
    flops: int
    bytes_moved: int

    @property
    def arithmetic_intensity(self) -> float:
        return self.flops / max(1, self.bytes_moved)

    def to_dict(self) -> dict:
        return {
            "flops": self.flops,
            "bytes_moved": self.bytes_moved,
            "arithmetic_intensity": self.arithmetic_intensity,
        }


def attention_flops_bytes(
    batch: int,
    seq_len: int,
    hidden_size: int,
    num_q_heads: int,
    num_kv_heads: int,
    head_dim: int,
    dtype: torch.dtype = torch.float16,
    *,
    # ---- MLA-only fields (pass for DeepSeek-V2 / V3 / similar) ----
    q_lora_rank: Optional[int] = None,
    kv_lora_rank: Optional[int] = None,
    qk_nope_head_dim: Optional[int] = None,
    qk_rope_head_dim: Optional[int] = None,
    v_head_dim: Optional[int] = None,
) -> RooflinePoint:
    # Dispatch: if any MLA field is set, route to the MLA accounting path.
    is_mla = any(x is not None for x in (
        kv_lora_rank, qk_nope_head_dim, qk_rope_head_dim, v_head_dim
    ))
    if is_mla:
        # All of the KV-side and dim-asymmetry fields are required together.
        # q_lora_rank may be None (V2-Lite path).
        for name, val in (("kv_lora_rank", kv_lora_rank),
                          ("qk_nope_head_dim", qk_nope_head_dim),
                          ("qk_rope_head_dim", qk_rope_head_dim),
                          ("v_head_dim", v_head_dim)):
            if val is None:
                raise ValueError(
                    f"MLA roofline accounting needs {name}; got None.")
        return _attention_flops_bytes_mla(
            batch, seq_len, hidden_size, num_q_heads,
            q_lora_rank, kv_lora_rank,
            qk_nope_head_dim, qk_rope_head_dim, v_head_dim,
            dtype,
        )

    B, S, H = batch, seq_len, hidden_size
    H_q, H_kv, D = num_q_heads, num_kv_heads, head_dim
    elem = torch.tensor([], dtype=dtype).element_size()

    q_out  = H_q * D
    kv_out = H_kv * D

    # --- FLOPs ---
    flops_q   = 2 * B * S * H * q_out
    flops_k   = 2 * B * S * H * kv_out
    flops_v   = 2 * B * S * H * kv_out
    flops_qk  = 2 * B * H_q * S * S * D
    flops_av  = 2 * B * H_q * S * S * D
    flops_o   = 2 * B * S * q_out * H
    flops = flops_q + flops_k + flops_v + flops_qk + flops_av + flops_o

    # --- Bytes (lower bound; SDPA may re-read tiles) ---
    bytes_input  = B * S * H * elem                      # hidden_states read
    bytes_w_q    = H * q_out * elem
    bytes_w_kv   = 2 * H * kv_out * elem
    bytes_w_o    = q_out * H * elem
    bytes_qkv_act = (B * S * (q_out + 2 * kv_out)) * elem
    bytes_attn_act = B * S * q_out * elem                # attention output
    bytes_output = B * S * H * elem
    bytes_moved = (
        bytes_input + bytes_w_q + bytes_w_kv + bytes_w_o
        + bytes_qkv_act + bytes_attn_act + bytes_output
    )

    return RooflinePoint(flops=flops, bytes_moved=bytes_moved)


def _attention_flops_bytes_mla(
    B: int, S: int, H: int, H_q: int,
    q_lora_rank: Optional[int],
    kv_lora_rank: int,
    qk_nope_head_dim: int,
    qk_rope_head_dim: int,
    v_head_dim: int,
    dtype: torch.dtype,
) -> RooflinePoint:
    """MLA-aware FLOPs / bytes for one prefill forward pass.

    Projection shapes (matches src/attention/deepseek_mla.py):
        q_a:    H -> q_lora_rank                        (skip if q_lora_rank=None)
        q_b:    q_lora_rank -> H_q * qk_head_dim
        kv_a:   H -> kv_lora_rank + qk_rope_head_dim    (combined)
        kv_b:   kv_lora_rank -> H_q * (qk_nope_head_dim + v_head_dim)
        o_proj: (H_q * v_head_dim) -> H

    Attention math:
        QK^T:  per-head head_dim = qk_head_dim
        AV:    per-head head_dim = v_head_dim   (NOT qk_head_dim — V is smaller)

    The wrapper pads V to qk_head_dim before SDPA so it can use
    FlashAttention; we count the *useful* AV FLOPs (v_head_dim) here,
    because the padded computation on zeros is overhead, not work. That
    overhead shows up indirectly as a lower achieved utilization — which
    is the right place to attribute it.
    """
    elem = torch.tensor([], dtype=dtype).element_size()
    qk_dim = qk_nope_head_dim + qk_rope_head_dim
    d_v = v_head_dim
    H_v_total = H_q * d_v

    # ---- FLOPs ----
    if q_lora_rank is not None:
        flops_q = (
            2 * B * S * H * q_lora_rank
            + 2 * B * S * q_lora_rank * (H_q * qk_dim)
        )
    else:
        flops_q = 2 * B * S * H * (H_q * qk_dim)
    flops_kv_down = 2 * B * S * H * (kv_lora_rank + qk_rope_head_dim)
    flops_kv_up   = 2 * B * S * kv_lora_rank * (H_q * (qk_nope_head_dim + d_v))
    flops_qk      = 2 * B * H_q * S * S * qk_dim
    flops_av      = 2 * B * H_q * S * S * d_v          # V is smaller, count honestly
    flops_o       = 2 * B * S * H_v_total * H
    flops = flops_q + flops_kv_down + flops_kv_up + flops_qk + flops_av + flops_o

    # ---- Bytes (lower bound) ----
    bytes_input = B * S * H * elem
    if q_lora_rank is not None:
        bytes_w_q = (H * q_lora_rank + q_lora_rank * H_q * qk_dim) * elem
    else:
        bytes_w_q = H * H_q * qk_dim * elem
    bytes_w_kv = (
        H * (kv_lora_rank + qk_rope_head_dim)
        + kv_lora_rank * H_q * (qk_nope_head_dim + d_v)
    ) * elem
    bytes_w_o = H_v_total * H * elem
    bytes_qkv_act = B * S * (H_q * qk_dim + H_q * (qk_nope_head_dim + d_v)
                              + qk_rope_head_dim) * elem
    bytes_attn_act = B * S * H_v_total * elem
    bytes_output = B * S * H * elem
    bytes_moved = (
        bytes_input + bytes_w_q + bytes_w_kv + bytes_w_o
        + bytes_qkv_act + bytes_attn_act + bytes_output
    )

    return RooflinePoint(flops=flops, bytes_moved=bytes_moved)
