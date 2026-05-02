"""Deterministic input generators.

Same seed + same (batch, seq_len, hidden) ⇒ bitwise-identical inputs
across all platforms. This is what makes the "black box gets the same
inputs" fairness contract real.
"""
from __future__ import annotations

from dataclasses import dataclass

import torch


@dataclass
class AttentionInputs:
    hidden_states: torch.Tensor      # (B, S, H)
    position_ids: torch.Tensor       # (B, S)
    attention_mask: torch.Tensor | None  # None ⇒ causal (handled by SDPA)


def make_inputs(
    batch: int,
    seq_len: int,
    hidden_size: int,
    *,
    dtype: torch.dtype = torch.float16,
    device: str | torch.device = "cpu",
    seed: int = 1234,
) -> AttentionInputs:
    g = torch.Generator(device="cpu").manual_seed(seed)
    # Generate on CPU first for cross-device determinism, then move.
    h = torch.randn(batch, seq_len, hidden_size, generator=g, dtype=torch.float32)
    h = h.to(device=device, dtype=dtype)
    pos = torch.arange(seq_len, device=device).unsqueeze(0).expand(batch, -1)
    return AttentionInputs(hidden_states=h, position_ids=pos, attention_mask=None)
