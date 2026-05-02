"""HF-reference equivalence tests.

Per METHODOLOGY.md, no timing numbers are accepted for a (model, platform,
precision) cell until we've confirmed that our wrapped `*Attention`
module produces outputs matching HuggingFace's native attention module
on bitwise-identical inputs, within a documented tolerance.

Runs on CPU in FP32 — the goal is to verify *math*, not kernel choice.

Each test:
  1. Loads our extracted single-layer safetensors.
  2. Builds HF's native attention module for the same layer_idx
     and copies the relevant weights in.
  3. Runs both on identical random `hidden_states` (seeded).
  4. Asserts element-wise closeness.

Two subtleties the test harness has to handle:

* HF's RoPE API moved between transformers 4.44 and 4.45. The attention
  block no longer computes `cos/sin` itself; the parent model computes
  them via `*RotaryEmbedding` and passes them in as `position_embeddings`.
  We detect this by inspecting `forward`'s signature and dispatch.

* HF's standalone `*Attention.forward(attention_mask=None)` does NOT
  apply a causal mask — the parent model is expected to build a 4D
  additive causal mask and pass it in. Calling the attention standalone
  with no mask runs *full* (non-causal) attention, which will silently
  disagree with our `is_causal=True` default on every token except the
  last. We hand every HF call an explicit causal mask to sidestep this.
"""
from __future__ import annotations

import inspect
from pathlib import Path

import pytest
import torch
import yaml
from safetensors.torch import load_file

ROOT = Path(__file__).resolve().parents[1]
CONFIGS = {
    "llama2_7b_mha":    ROOT / "configs" / "llama2_7b_mha.yaml",
    "starcoder_7b_mqa": ROOT / "configs" / "starcoder_7b_mqa.yaml",
    "mistral_7b_gqa":   ROOT / "configs" / "mistral_7b_gqa.yaml",
}

ATOL = 1e-4
RTOL = 1e-4


def _load_cfg(name: str):
    from src.attention.base import AttentionConfig
    with open(CONFIGS[name]) as f:
        d = yaml.safe_load(f)
    return AttentionConfig(**{k: v for k, v in d.items() if k in AttentionConfig.__dataclass_fields__})


def _require_weights(cfg) -> Path:
    path = ROOT / cfg.weights_path
    if not path.exists():
        pytest.skip(
            f"weights not extracted yet: {path}. "
            f"Run `python scripts/extract_weights.py --config configs/{cfg.name}.yaml`."
        )
    return path


def _strip_layer_prefix(sd: dict, prefixes: list[str]) -> dict:
    out = {}
    for k, v in sd.items():
        new_k = k
        for pref in prefixes:
            if k.startswith(pref):
                new_k = k[len(pref):]
                break
        out[new_k] = v
    return out


def _make_inputs(batch, seq, hidden):
    g = torch.Generator().manual_seed(0)
    h = torch.randn(batch, seq, hidden, generator=g, dtype=torch.float32)
    pos = torch.arange(seq).unsqueeze(0).expand(batch, -1).contiguous()
    return h, pos


def _causal_additive_mask(seq_len: int, dtype=torch.float32) -> torch.Tensor:
    """4D causal mask, additive form: 0 where allowed, -inf where blocked.
    Llama and Mistral's HF attention modules expect this convention."""
    m = torch.full((1, 1, seq_len, seq_len), float("-inf"), dtype=dtype)
    return torch.triu(m, diagonal=1)


def _causal_bool_mask(seq_len: int) -> torch.Tensor:
    """4D causal mask, boolean form: True where allowed to attend.
    `gpt_bigcode`'s `_attn` uses `torch.where(mask, scores, -inf)` and
    the type check requires a bool tensor. `F.scaled_dot_product_attention`
    also accepts bool masks (True = attend), so the same tensor works
    for both sides of the comparison."""
    return torch.tril(torch.ones(1, 1, seq_len, seq_len, dtype=torch.bool))


def _call_hf_rope_attention(hf_attn, hf_cfg, rope_cls, h, pos, attn_mask):
    """Call an HF attention module that uses RoPE, handling both the
    pre-4.45 and post-4.45 calling conventions.

    Pre-4.45: forward(hidden_states, attention_mask, position_ids, ...)
    Post-4.45: forward(hidden_states, position_embeddings=(cos, sin),
                       attention_mask, ...)
    """
    sig = inspect.signature(hf_attn.forward)
    kwargs = {"hidden_states": h, "attention_mask": attn_mask}
    if "position_embeddings" in sig.parameters:
        # New API: compute cos/sin via the rotary embedding module, pass
        # them in as a tuple. rope_cls's ctor also varies (some versions
        # want `config`, some want head_dim/max_pos/base) — call it the
        # documented way for whatever version is installed.
        try:
            rope = rope_cls(config=hf_cfg).to(dtype=torch.float32).eval()
        except TypeError:
            rope = rope_cls(
                hf_cfg.hidden_size // hf_cfg.num_attention_heads,
                max_position_embeddings=hf_cfg.max_position_embeddings,
                base=hf_cfg.rope_theta,
            ).to(dtype=torch.float32).eval()
        # Newer RoPE modules take (hidden_states, position_ids) and
        # return (cos, sin) in the shape (B, S, D_head).
        cos, sin = rope(h, pos)
        kwargs["position_embeddings"] = (cos, sin)
    if "position_ids" in sig.parameters:
        kwargs["position_ids"] = pos
    out = hf_attn(**kwargs)
    return out[0] if isinstance(out, tuple) else out


# ---------------------------------------------------------------------------
# Llama-2 (MHA)
# ---------------------------------------------------------------------------

def test_llama_mha_matches_hf():
    from src.attention.llama_mha import LlamaMHA
    from transformers import LlamaConfig
    from transformers.models.llama.modeling_llama import (
        LlamaAttention,
        LlamaRotaryEmbedding,
    )

    cfg = _load_cfg("llama2_7b_mha")
    weights_path = _require_weights(cfg)

    our = LlamaMHA(cfg)
    our.load_weights(str(weights_path))
    our = our.to(dtype=torch.float32).eval()

    hf_cfg = LlamaConfig(
        hidden_size=cfg.hidden_size,
        num_attention_heads=cfg.num_attention_heads,
        num_key_value_heads=cfg.num_key_value_heads,
        max_position_embeddings=cfg.max_position_embeddings,
        rope_theta=cfg.rope_theta,
        attention_bias=False,
    )
    hf_attn = LlamaAttention(hf_cfg, layer_idx=0).to(dtype=torch.float32).eval()
    raw = load_file(str(weights_path))
    stripped = _strip_layer_prefix(raw, [f"model.layers.{cfg.layer_index}.self_attn."])
    missing, _ = hf_attn.load_state_dict(
        {k: v.float() for k, v in stripped.items()},
        strict=False,
    )
    assert not missing, f"HF LlamaAttention missing keys: {missing}"

    seq = 64
    h, pos = _make_inputs(batch=1, seq=seq, hidden=cfg.hidden_size)
    mask = _causal_additive_mask(seq)

    with torch.no_grad():
        ours = our(h, pos, mask)
        hf_out = _call_hf_rope_attention(hf_attn, hf_cfg, LlamaRotaryEmbedding, h, pos, mask)

    max_diff = (ours - hf_out).abs().max().item()
    assert torch.allclose(ours, hf_out, atol=ATOL, rtol=RTOL), (
        f"Llama MHA output mismatch: max abs diff = {max_diff:.4e}"
    )


# ---------------------------------------------------------------------------
# Mistral (GQA)
# ---------------------------------------------------------------------------

def test_mistral_gqa_matches_hf():
    from src.attention.mistral_gqa import MistralGQA
    from transformers import MistralConfig
    from transformers.models.mistral.modeling_mistral import (
        MistralAttention,
        MistralRotaryEmbedding,
    )

    cfg = _load_cfg("mistral_7b_gqa")
    weights_path = _require_weights(cfg)

    our = MistralGQA(cfg)
    our.load_weights(str(weights_path))
    our = our.to(dtype=torch.float32).eval()

    hf_cfg = MistralConfig(
        hidden_size=cfg.hidden_size,
        num_attention_heads=cfg.num_attention_heads,
        num_key_value_heads=cfg.num_key_value_heads,
        max_position_embeddings=cfg.max_position_embeddings,
        rope_theta=cfg.rope_theta,
        sliding_window=cfg.sliding_window or cfg.max_position_embeddings,
    )
    hf_attn = MistralAttention(hf_cfg, layer_idx=0).to(dtype=torch.float32).eval()
    raw = load_file(str(weights_path))
    stripped = _strip_layer_prefix(raw, [f"model.layers.{cfg.layer_index}.self_attn."])
    missing, _ = hf_attn.load_state_dict(
        {k: v.float() for k, v in stripped.items()},
        strict=False,
    )
    assert not missing, f"HF MistralAttention missing keys: {missing}"

    # Stay well under sliding-window size so our dense path and HF's SWA
    # path produce identical math.
    seq = min(64, (cfg.sliding_window or 4096))
    h, pos = _make_inputs(batch=1, seq=seq, hidden=cfg.hidden_size)
    mask = _causal_additive_mask(seq)

    with torch.no_grad():
        ours = our(h, pos, mask)
        hf_out = _call_hf_rope_attention(hf_attn, hf_cfg, MistralRotaryEmbedding, h, pos, mask)

    max_diff = (ours - hf_out).abs().max().item()
    assert torch.allclose(ours, hf_out, atol=ATOL, rtol=RTOL), (
        f"Mistral GQA output mismatch: max abs diff = {max_diff:.4e}"
    )


# ---------------------------------------------------------------------------
# StarCoderBase (MQA)
# ---------------------------------------------------------------------------

def test_starcoder_mqa_matches_hf():
    from src.attention.starcoder_mqa import StarCoderMQA
    from transformers import GPTBigCodeConfig
    from transformers.models.gpt_bigcode.modeling_gpt_bigcode import GPTBigCodeAttention

    cfg = _load_cfg("starcoder_7b_mqa")
    weights_path = _require_weights(cfg)

    our = StarCoderMQA(cfg)
    our.load_weights(str(weights_path))
    our = our.to(dtype=torch.float32).eval()

    hf_cfg = GPTBigCodeConfig(
        n_embd=cfg.hidden_size,
        n_head=cfg.num_attention_heads,
        n_positions=cfg.max_position_embeddings,
        multi_query=True,
    )
    hf_attn = GPTBigCodeAttention(hf_cfg, layer_idx=0).to(dtype=torch.float32).eval()
    raw = load_file(str(weights_path))
    layer_pref = f"transformer.h.{cfg.layer_index}.attn."
    attn_sd = {
        k[len(layer_pref):]: v.float() for k, v in raw.items() if k.startswith(layer_pref)
    }
    missing, _ = hf_attn.load_state_dict(attn_sd, strict=False)
    assert not missing, f"HF GPTBigCodeAttention missing keys: {missing}"

    # StarCoder's learned absolute positions get added to hidden_states
    # BEFORE the attention block — the attention module itself doesn't
    # know about them. Our wrapper adds them inside via the encoder; for
    # the HF path we add them manually so both paths see the same Q/K/V
    # projections.
    wpe = raw["transformer.wpe.weight"].float()
    seq = 64
    h, pos = _make_inputs(batch=1, seq=seq, hidden=cfg.hidden_size)
    h_with_pe = h + wpe[pos]

    # Two masks, same semantics, different layouts:
    #   SDPA (our impl) wants (B, H, S_q, S_k) -> broadcast with (1, 1, S, S).
    #   gpt_bigcode's MQA path produces attn_weights shaped
    #     (B, S_q, H, S_k), so `torch.where(mask, ...)` wants a mask that
    #     broadcasts to that, i.e. (1, S_q, 1, S_k).
    mask_sdpa = _causal_bool_mask(seq)                  # (1, 1, S, S)
    mask_gpt = mask_sdpa.permute(0, 2, 1, 3).contiguous()  # (1, S, 1, S)

    with torch.no_grad():
        ours = our(h, pos, mask_sdpa)
        hf_out = hf_attn(hidden_states=h_with_pe, attention_mask=mask_gpt)
        hf_out = hf_out[0] if isinstance(hf_out, tuple) else hf_out

    max_diff = (ours - hf_out).abs().max().item()
    assert torch.allclose(ours, hf_out, atol=ATOL, rtol=RTOL), (
        f"StarCoder MQA output mismatch: max abs diff = {max_diff:.4e}"
    )
