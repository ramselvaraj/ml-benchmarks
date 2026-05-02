"""StarCoderBase-7B attention layer (MQA, gpt_bigcode architecture).

StarCoderBase-7B is the canonical 7B-class MQA model. Positional
encoding is **learned absolute** (GPT-2 style `wpe` table), not RoPE —
that's why `_impl.AttentionImpl` takes a pluggable `PositionalEncoder`.

gpt_bigcode fuses Q, K, and V into a single `c_attn.weight` tensor with
layout (rows first):

    [Q_head_0 || Q_head_1 || ... || Q_head_{H_q-1} || K_shared || V_shared]

i.e. shape `((H_q + 2) * D, hidden)`. Note there is only ONE K head and
ONE V head (MQA), so the "+2" is literal. The output projection and
position embedding are separate:

    transformer.h.{i}.attn.c_attn.weight   # (H_q+2)*D, hidden)
    transformer.h.{i}.attn.c_attn.bias     # (H_q+2)*D,)
    transformer.h.{i}.attn.c_proj.weight   # (hidden, H_q*D)
    transformer.h.{i}.attn.c_proj.bias     # (hidden,)
    transformer.wpe.weight                 # (max_pos, hidden)

Gated access warning: `bigcode/starcoderbase-7b` is gated on HF. Run
`huggingface-cli login` with a token that has been approved for the
model before invoking `extract_weights.py`. If you can't get access,
fall back to implementing ALiBi and staying on Falcon-7B (see docs).
"""
from __future__ import annotations

import torch
from safetensors.torch import load_file

from .base import AttentionConfig, AttentionModule
from ._impl import AttentionImpl
from .positional import LearnedAbsoluteEncoder


class StarCoderMQA(AttentionModule):
    def __init__(self, cfg: AttentionConfig):
        super().__init__(cfg)
        if cfg.num_key_value_heads != 1:
            raise ValueError(
                f"StarCoderBase uses MQA with num_kv_heads=1, "
                f"got {cfg.num_key_value_heads}."
            )
        self.impl = AttentionImpl(
            hidden_size=cfg.hidden_size,
            num_q_heads=cfg.num_attention_heads,
            num_kv_heads=cfg.num_key_value_heads,
            head_dim=cfg.head_dim,
            positional_encoder=LearnedAbsoluteEncoder(
                max_pos=cfg.max_position_embeddings,
                hidden_size=cfg.hidden_size,
            ),
            # gpt_bigcode c_attn and c_proj both have biases.
            bias_qkv=True,
            bias_o=True,
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
        H_q, H_kv, D = (
            self.cfg.num_attention_heads,
            self.cfg.num_key_value_heads,
            self.cfg.head_dim,
        )
        assert H_kv == 1, "gpt_bigcode is MQA; num_kv_heads must be 1."

        c_attn_w_key = f"transformer.h.{i}.attn.c_attn.weight"
        c_attn_b_key = f"transformer.h.{i}.attn.c_attn.bias"
        c_proj_w_key = f"transformer.h.{i}.attn.c_proj.weight"
        c_proj_b_key = f"transformer.h.{i}.attn.c_proj.bias"
        wpe_key = "transformer.wpe.weight"

        for k in (c_attn_w_key, c_attn_b_key, c_proj_w_key, c_proj_b_key, wpe_key):
            if k not in sd:
                raise KeyError(f"StarCoder weight key not found: {k}")

        qkv_w = sd[c_attn_w_key]  # ((H_q + 2) * D, hidden)
        qkv_b = sd[c_attn_b_key]  # ((H_q + 2) * D,)
        expected_rows = (H_q + 2) * D
        if qkv_w.shape[0] != expected_rows:
            raise RuntimeError(
                f"Unexpected c_attn rows: got {qkv_w.shape[0]}, "
                f"expected {expected_rows} = (num_q_heads + 2) * head_dim."
            )

        q_w = qkv_w[: H_q * D, :]
        k_w = qkv_w[H_q * D : H_q * D + D, :]
        v_w = qkv_w[H_q * D + D : H_q * D + 2 * D, :]
        q_b = qkv_b[: H_q * D]
        k_b = qkv_b[H_q * D : H_q * D + D]
        v_b = qkv_b[H_q * D + D : H_q * D + 2 * D]

        new_sd = {
            "q_proj.weight": q_w.contiguous(),
            "q_proj.bias":   q_b.contiguous(),
            "k_proj.weight": k_w.contiguous(),
            "k_proj.bias":   k_b.contiguous(),
            "v_proj.weight": v_w.contiguous(),
            "v_proj.bias":   v_b.contiguous(),
            "o_proj.weight": sd[c_proj_w_key],
            "o_proj.bias":   sd[c_proj_b_key],
        }
        self.impl.load_state_dict(new_sd, strict=False)

        # Learned position embeddings live on the encoder, not the impl.
        pe_sd = {"wpe.weight": sd[wpe_key]}
        self.impl.pe.load_state_dict(pe_sd, strict=True)
