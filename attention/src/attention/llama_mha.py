"""Llama-2-7B attention layer (MHA, 32/32 heads, RoPE)."""
from __future__ import annotations

import torch
from safetensors.torch import load_file

from .base import AttentionConfig, AttentionModule
from ._impl import AttentionImpl
from .positional import RoPEEncoder


class LlamaMHA(AttentionModule):
    HF_KEYS = {
        "q_proj.weight": "model.layers.{i}.self_attn.q_proj.weight",
        "k_proj.weight": "model.layers.{i}.self_attn.k_proj.weight",
        "v_proj.weight": "model.layers.{i}.self_attn.v_proj.weight",
        "o_proj.weight": "model.layers.{i}.self_attn.o_proj.weight",
    }

    def __init__(self, cfg: AttentionConfig):
        super().__init__(cfg)
        self.impl = AttentionImpl(
            hidden_size=cfg.hidden_size,
            num_q_heads=cfg.num_attention_heads,
            num_kv_heads=cfg.num_key_value_heads,
            head_dim=cfg.head_dim,
            positional_encoder=RoPEEncoder(
                head_dim=cfg.head_dim,
                max_pos=cfg.max_position_embeddings,
                base=cfg.rope_theta,
            ),
            bias_qkv=False,
            bias_o=False,
        )

    def forward(self, hidden_states, position_ids, attention_mask=None):
        return self.impl(hidden_states, position_ids, attention_mask)

    def forward_decode(self, hidden_state, position_ids, past_kv=None):
        return self.impl.forward_decode(hidden_state, position_ids, past_kv)

    def precompute_kv(self, hidden_states, position_ids):
        return self.impl.precompute_kv(hidden_states, position_ids)

    def precompute_kv_into_buffer(self, hidden_states, position_ids, k_cache, v_cache):
        return self.impl.precompute_kv_into_buffer(hidden_states, position_ids, k_cache, v_cache)

    def forward_decode_inplace(self, hidden_state, position_ids, k_cache, v_cache, cache_len):
        return self.impl.forward_decode_inplace(hidden_state, position_ids, k_cache, v_cache, cache_len)

    def random_init(self, dtype: torch.dtype = torch.float16) -> None:
        self.impl.to(dtype=dtype)

    def load_weights(self, path: str) -> None:
        sd = load_file(path)
        i = self.cfg.layer_index
        remap = {ours: src.format(i=i) for ours, src in self.HF_KEYS.items()}
        new_sd = {ours: sd[src] for ours, src in remap.items() if src in sd}
        missing_expected = set(self.HF_KEYS) - set(new_sd)
        if missing_expected:
            raise RuntimeError(
                f"Missing expected keys when loading Llama MHA from {path}: "
                f"{sorted(missing_expected)}"
            )
        _, unexpected = self.impl.load_state_dict(new_sd, strict=False)
        # RoPE encoder has no trainable params, so no missing keys from it.
