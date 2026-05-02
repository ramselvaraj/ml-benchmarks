"""Common interface for an attention "black box".

Every variant (MHA / MQA / GQA) implements this interface so the runners
can treat them identically. The contract is intentionally narrow:

    forward(hidden_states, position_ids, attention_mask) -> hidden_states

with shapes:
    hidden_states:    (batch, seq, hidden)
    position_ids:     (batch, seq)
    attention_mask:   (batch, 1, seq, seq) or None for causal-default
    return:           (batch, seq, hidden)
"""
from __future__ import annotations

from abc import ABC, abstractmethod
from dataclasses import dataclass, field
from typing import Optional

import torch
import torch.nn as nn


@dataclass
class AttentionConfig:
    name: str
    variant: str                 # "MHA" | "MQA" | "GQA" | "MLA"
    hidden_size: int
    num_attention_heads: int
    num_key_value_heads: int
    head_dim: int
    max_position_embeddings: int = 4096
    rope_theta: float = 10000.0
    sliding_window: Optional[int] = None
    layer_index: int = 0
    weights_path: Optional[str] = None
    hf_repo: Optional[str] = None
    sweeps: dict = field(default_factory=dict)
    warmup: int = 10
    iters: int = 50
    # ---- MLA-only fields (DeepSeek-V2-style multi-head latent attention) ----
    # All None for MHA/MQA/GQA models — the wrapper checks variant=="MLA" before
    # touching them. Set these for MLA configs:
    #   q_lora_rank        — Q-side latent dim (None ⇒ no Q low-rank, V2-Lite path)
    #   kv_lora_rank       — KV-side latent dim (e.g. 512 for DeepSeek-V2)
    #   qk_nope_head_dim   — per-head dim of the rope-free QK channel (e.g. 128)
    #   qk_rope_head_dim   — per-head dim of the rope-only QK channel (e.g. 64)
    #   v_head_dim         — per-head V dim (e.g. 128 — usually != qk_head_dim)
    # When MLA is active, head_dim is redundant; effective QK head_dim is
    # qk_nope_head_dim + qk_rope_head_dim, and effective V head_dim is v_head_dim.
    q_lora_rank: Optional[int] = None
    kv_lora_rank: Optional[int] = None
    qk_nope_head_dim: Optional[int] = None
    qk_rope_head_dim: Optional[int] = None
    v_head_dim: Optional[int] = None

    @property
    def kv_groups(self) -> int:
        return self.num_attention_heads // self.num_key_value_heads


class AttentionModule(nn.Module, ABC):
    """Abstract wrapper around a HuggingFace `*Attention` layer."""

    def __init__(self, cfg: AttentionConfig):
        super().__init__()
        self.cfg = cfg

    @abstractmethod
    def forward(
        self,
        hidden_states: torch.Tensor,
        position_ids: torch.Tensor,
        attention_mask: Optional[torch.Tensor] = None,
    ) -> torch.Tensor:
        ...

    @abstractmethod
    def load_weights(self, path: str) -> None:
        """Populate parameters from a single-layer .safetensors file."""

    @abstractmethod
    def random_init(self, dtype: torch.dtype = torch.float16) -> None:
        """Initialize parameters randomly (for --dry-run)."""
