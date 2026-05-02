"""Pluggable positional encoders.

Different 7B-class models use different positional-encoding schemes, and
pretending they all use RoPE is how the original scaffolding ended up
silently wrong for Falcon-7B. We model positional encoding as a strategy
object with three optional hooks:

    hook_pre_projection(hidden_states, position_ids) -> hidden_states
        Called once before Q/K/V projection. Used by models with learned
        absolute position embeddings (GPT-2, StarCoder's gpt_bigcode).

    hook_qk(q, k, position_ids) -> (q, k)
        Called after Q/K projection and head reshape. Used by RoPE.

    hook_attn_bias(attn_mask, seq_len, device, dtype) -> attn_mask
        Called just before SDPA. Used by ALiBi, where positional info is
        injected as an additive bias on the attention-score matrix.

Each hook defaults to a no-op so an encoder only overrides what it
actually needs. This keeps the shared AttentionImpl honest: it calls
every hook, and the encoder decides whether that hook is live.
"""
from __future__ import annotations

from typing import Optional

import torch
import torch.nn as nn


class PositionalEncoder(nn.Module):
    """Base class. Subclasses override whichever hooks they need."""

    def hook_pre_projection(
        self, hidden_states: torch.Tensor, position_ids: torch.Tensor
    ) -> torch.Tensor:
        return hidden_states

    def hook_qk(
        self, q: torch.Tensor, k: torch.Tensor, position_ids: torch.Tensor
    ) -> tuple[torch.Tensor, torch.Tensor]:
        return q, k

    def hook_attn_bias(
        self,
        attn_mask: Optional[torch.Tensor],
        seq_len: int,
        device: torch.device,
        dtype: torch.dtype,
    ) -> Optional[torch.Tensor]:
        return attn_mask


class NoOpEncoder(PositionalEncoder):
    """For benches where you don't care about position. Not used by any
    real model here, but useful in unit tests."""


class RoPEEncoder(PositionalEncoder):
    """Rotary position embedding (Llama, Mistral, most modern 7B models).

    The rotation convention here matches HuggingFace's `apply_rotary_pos_emb`
    in both `modeling_llama.py` and `modeling_mistral.py`:
        x' = x * cos + rotate_half(x) * sin
    with `rotate_half([x1, x2]) = [-x2, x1]` over the head_dim-split halves.
    """

    def __init__(self, head_dim: int, max_pos: int, base: float = 10000.0):
        super().__init__()
        self.head_dim = head_dim
        self.max_pos = max_pos
        self.base = base
        # Precompute inv_freq once on CPU, register as buffer so it moves
        # with .to(device). cos/sin are built lazily on first forward.
        inv_freq = 1.0 / (
            base ** (torch.arange(0, head_dim, 2, dtype=torch.float32) / head_dim)
        )
        self.register_buffer("inv_freq", inv_freq, persistent=False)
        self._cached: Optional[tuple[torch.Tensor, torch.Tensor, int]] = None

    def _cos_sin(self, seq_len: int, device: torch.device, dtype: torch.dtype):
        need = max(seq_len, self.max_pos)
        if (
            self._cached is None
            or self._cached[2] < need
            or self._cached[0].device != device
            or self._cached[0].dtype != dtype
        ):
            t = torch.arange(need, device=device, dtype=torch.float32)
            freqs = torch.outer(t, self.inv_freq.to(device))
            emb = torch.cat((freqs, freqs), dim=-1)
            self._cached = (emb.cos().to(dtype), emb.sin().to(dtype), need)
        cos, sin, _ = self._cached
        return cos, sin

    @staticmethod
    def _rotate_half(x: torch.Tensor) -> torch.Tensor:
        x1, x2 = x[..., : x.shape[-1] // 2], x[..., x.shape[-1] // 2 :]
        return torch.cat((-x2, x1), dim=-1)

    def hook_qk(self, q, k, position_ids):
        # q, k: (B, H, S, D). position_ids: (B, S).
        B, _, S, D = q.shape
        # Cache must cover every absolute position we'll index into. At
        # decode-time, position_ids contains positions well past S — they
        # are the running "current sequence length" — so size the cache by
        # max(position) + 1, not by the local S.
        needed = int(position_ids.max().item()) + 1
        cos, sin = self._cos_sin(needed, q.device, q.dtype)
        # Gather per-position cos/sin — supports arbitrary position_ids.
        # position_ids shape (B, S) -> (B, 1, S, D)
        cos = cos[position_ids].unsqueeze(1)  # (B, 1, S, D)
        sin = sin[position_ids].unsqueeze(1)
        q_rot = (q * cos) + (self._rotate_half(q) * sin)
        k_rot = (k * cos) + (self._rotate_half(k) * sin)
        return q_rot, k_rot


class LearnedAbsoluteEncoder(PositionalEncoder):
    """Learned absolute position embeddings (GPT-2, StarCoder's gpt_bigcode).

    Adds a position-indexed embedding to `hidden_states` *before* QKV
    projection. The embedding table is a trained parameter loaded from
    the model checkpoint.
    """

    def __init__(self, max_pos: int, hidden_size: int):
        super().__init__()
        self.wpe = nn.Embedding(max_pos, hidden_size)

    def hook_pre_projection(self, hidden_states, position_ids):
        # hidden_states: (B, S, H). position_ids: (B, S).
        return hidden_states + self.wpe(position_ids)
