"""Quantize extracted attention-layer weights into packed INT8 / INT4 plus
scales, and write them to a new `.safetensors` file.

This script is the **source of truth** for quantization geometry across
platforms:

    - Per-channel symmetric INT8 along out_features (standard LLM convention)
    - Per-group symmetric INT4 (group_size=128) along in_features

The GPU runner passes torchao the same original weights and torchao's
internal quantizer re-derives the same packed bytes (uniform symmetric
with matching group_size); the FPGA HLS kernel reads the packed output
of this script directly. Both paths consume the same quantization
scheme, so their outputs must match within `atol`.

Output schema (single `.safetensors`):

    # INT8 file (weights/<model>_int8_layer0.safetensors):
    q_proj.q_weight      int8    (out_features, in_features)
    q_proj.scales        fp16    (out_features,)        # per-channel
    k_proj.q_weight      int8    ...
    k_proj.scales        fp16    ...
    v_proj.q_weight      int8    ...
    v_proj.scales        fp16    ...
    o_proj.q_weight      int8    ...
    o_proj.scales        fp16    ...
    # INT4 file (weights/<model>_int4_layer0.safetensors):
    q_proj.q_weight_packed  uint8  (out_features, in_features/2)     # packed 2-per-byte
    q_proj.scales           fp16   (out_features, in_features/128)   # per-group
    ...
    _metadata (as JSON in safetensors metadata):
    {
      "scheme": "symmetric_per_channel_int8" | "symmetric_per_group_int4",
      "group_size": 128,
      "quant_axis": 1,
      "packing": "low_nibble_first",
      "range": [-127, 127] | [-7, 7],
      "source_weights": "weights/<model>_layer0.safetensors",
      "source_keys": ["model.layers.0.self_attn.q_proj.weight", ...]
    }

Usage:
    python scripts/quantize_weights.py --config configs/llama2_7b_mha.yaml --precision int4
    python scripts/quantize_weights.py --config configs/llama2_7b_mha.yaml --precision int8
"""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

import torch
import yaml
from safetensors.torch import load_file, save_file

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))


# -----------------------------------------------------------------------------
# Core quantization kernels — simple, deterministic, library-agnostic.
# -----------------------------------------------------------------------------

def quantize_int8_symmetric_per_channel(w: torch.Tensor) -> tuple[torch.Tensor, torch.Tensor]:
    """Symmetric per-channel INT8 along the OUTPUT axis (dim 0) for an
    nn.Linear weight of shape (out_features, in_features).

    Returns:
        q_weight: int8 tensor, same shape as `w`
        scales:   fp16 tensor of shape (out_features,)

    Dequant: w_hat = q_weight.float() * scales[:, None]
    """
    assert w.dim() == 2, f"expected 2D weight, got shape {w.shape}"
    w32 = w.to(torch.float32)
    # Per-output-channel max abs; clamp to avoid div-by-zero for dead channels.
    s_max = w32.abs().amax(dim=1).clamp_min(1e-8)
    scales = s_max / 127.0
    q = torch.round(w32 / scales[:, None]).clamp(-127, 127).to(torch.int8)
    return q, scales.to(torch.float16)


def quantize_int4_symmetric_per_group(
    w: torch.Tensor, group_size: int = 128
) -> tuple[torch.Tensor, torch.Tensor]:
    """Symmetric per-group INT4 along the INPUT axis (dim 1), group_size
    elements per group. Standard LLM convention (matches torchao
    int4_weight_only, Marlin, GPTQ, AWQ).

    `in_features` must be divisible by `group_size`.

    Returns:
        q_packed: uint8 tensor of shape (out_features, in_features // 2)
                  — each byte holds two INT4 values, low nibble first.
        scales:   fp16 tensor of shape (out_features, in_features // group_size)

    Dequant:
        q_unpacked[:, 0::2] = (q_packed & 0x0F).to(int8) - (mask-sign)
        q_unpacked[:, 1::2] = (q_packed >> 4).to(int8) - (mask-sign)
        then reshape to groups and multiply by scales.
    """
    assert w.dim() == 2, f"expected 2D weight, got shape {w.shape}"
    O, I = w.shape
    assert I % group_size == 0, (
        f"in_features={I} must be divisible by group_size={group_size}"
    )
    G = I // group_size

    w32 = w.to(torch.float32)
    w_grouped = w32.view(O, G, group_size)
    s_max = w_grouped.abs().amax(dim=-1).clamp_min(1e-8)   # (O, G)
    scales = s_max / 7.0                                    # INT4 range [-7, 7]
    q = torch.round(w_grouped / scales[..., None]).clamp(-7, 7).to(torch.int8)
    q = q.view(O, I)                                        # signed INT4, stored as int8

    # Pack two signed-INT4 nibbles per byte, low-nibble-first.
    # Convert signed -7..7 to 4-bit two's complement uint4 0..15 via (& 0x0F).
    q_u4 = (q & 0x0F).to(torch.uint8)                       # (O, I)
    low  = q_u4[:, 0::2]                                    # (O, I/2)
    high = q_u4[:, 1::2]                                    # (O, I/2)
    q_packed = (low | (high << 4)).to(torch.uint8)          # (O, I/2)

    return q_packed, scales.to(torch.float16)


def dequantize_int8(q_weight: torch.Tensor, scales: torch.Tensor) -> torch.Tensor:
    """Inverse of quantize_int8_symmetric_per_channel. Returns fp32."""
    return q_weight.to(torch.float32) * scales.to(torch.float32)[:, None]


def dequantize_int4(
    q_packed: torch.Tensor, scales: torch.Tensor, group_size: int = 128
) -> torch.Tensor:
    """Inverse of quantize_int4_symmetric_per_group. Returns fp32."""
    O, I_half = q_packed.shape
    I = I_half * 2
    G = I // group_size
    # Unpack nibbles; sign-extend 4-bit two's complement.
    low  = (q_packed & 0x0F).to(torch.int8)
    high = ((q_packed >> 4) & 0x0F).to(torch.int8)
    # Sign-extend: if value >= 8, subtract 16.
    low  = torch.where(low  >= 8, low  - 16, low)
    high = torch.where(high >= 8, high - 16, high)
    q_unpacked = torch.empty(O, I, dtype=torch.int8)
    q_unpacked[:, 0::2] = low
    q_unpacked[:, 1::2] = high
    w = q_unpacked.view(O, G, group_size).to(torch.float32) * scales.to(torch.float32)[..., None]
    return w.view(O, I)


# -----------------------------------------------------------------------------
# Sanity: round-trip check so we never ship a quantizer that can't invert.
# -----------------------------------------------------------------------------

def _round_trip_check_int8(w: torch.Tensor) -> float:
    q, s = quantize_int8_symmetric_per_channel(w)
    w_hat = dequantize_int8(q, s)
    return (w.float() - w_hat).abs().max().item()


def _round_trip_check_int4(w: torch.Tensor, group_size: int = 128) -> float:
    q, s = quantize_int4_symmetric_per_group(w, group_size)
    w_hat = dequantize_int4(q, s, group_size)
    return (w.float() - w_hat).abs().max().item()


# -----------------------------------------------------------------------------
# Driver
# -----------------------------------------------------------------------------

# Which safetensors keys to quantize. We quantize only the linear
# projection weights; biases (if any, e.g. StarCoder), layernorm scales
# (e.g. MLA's q_a_layernorm and kv_a_layernorm), and position embeddings
# stay in full precision — they're tiny and quantizing them hurts accuracy
# disproportionately.
_LINEAR_KEY_PATTERNS = [
    # Llama / Mistral
    ".q_proj.weight", ".k_proj.weight", ".v_proj.weight", ".o_proj.weight",
    # Falcon (legacy — not in current registry but harmless)
    ".query_key_value.weight", ".dense.weight",
    # StarCoder / gpt_bigcode
    ".c_attn.weight", ".c_proj.weight",
    # DeepSeek-V2/V3 MLA — five linear projections per attention layer.
    # The two RMSNorms (q_a_layernorm, kv_a_layernorm) are NOT quantized;
    # they're tiny and matching ".weight" against them would trigger here
    # by accident, so we use the full ".q_a_proj.weight" pattern etc.
    ".q_a_proj.weight",            # H -> q_lora_rank
    ".q_b_proj.weight",            # q_lora_rank -> H_q * q_head_dim
    ".q_proj.weight",              # (V2-Lite path) — already covered above
    ".kv_a_proj_with_mqa.weight",  # H -> kv_lora_rank + qk_rope_head_dim
    ".kv_b_proj.weight",           # kv_lora_rank -> H_q * (qk_nope_head_dim + v_head_dim)
]


def _is_linear_weight(key: str) -> bool:
    return any(pat in key for pat in _LINEAR_KEY_PATTERNS)


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--config", required=True, help="configs/<model>.yaml")
    p.add_argument("--precision", required=True, choices=["int8", "int4"])
    p.add_argument("--group-size", type=int, default=128,
                   help="INT4 group size (ignored for INT8). Default 128.")
    p.add_argument("--strict", action="store_true",
                   help="Fail on any round-trip error > rtol instead of warning.")
    p.add_argument("--rtol", type=float, default=5e-2,
                   help="Round-trip max-abs-error threshold (warn/fail).")
    args = p.parse_args()

    with open(args.config) as f:
        cfg = yaml.safe_load(f)
    if cfg.get("deprecated"):
        raise SystemExit(f"{args.config} is deprecated.")

    src_path = ROOT / cfg["weights_path"]
    if not src_path.exists():
        raise SystemExit(
            f"Source weights not found: {src_path}\n"
            f"Run `python scripts/extract_weights.py --config {args.config}` first."
        )

    # Derive output path: weights/<model>_<precision>_layer0.safetensors
    out_name = src_path.stem.replace("_layer0", f"_{args.precision}_layer0") + ".safetensors"
    out_path = src_path.parent / out_name

    print(f"[quantize] {src_path.name}  scheme={args.precision}")
    sd = load_file(str(src_path))
    out_sd: dict[str, torch.Tensor] = {}

    metadata = {
        "precision": args.precision,
        "scheme": (
            "symmetric_per_channel_int8" if args.precision == "int8"
            else "symmetric_per_group_int4"
        ),
        "group_size": str(args.group_size) if args.precision == "int4" else "n/a",
        "quant_axis": "0" if args.precision == "int8" else "1",
        "packing": "n/a" if args.precision == "int8" else "low_nibble_first_little_endian",
        "range": "[-127,127]" if args.precision == "int8" else "[-7,7]",
        "source_weights": str(cfg["weights_path"]),
    }

    n_quantized = 0
    max_error = 0.0
    for key, tensor in sd.items():
        if not _is_linear_weight(key):
            # Pass through (biases, wpe embeddings, etc.)
            out_sd[key] = tensor
            continue

        if tensor.dim() != 2:
            # Some fused tensors (Falcon's query_key_value) are 2D already;
            # others might not be. Skip anything we can't handle.
            print(f"[quantize] SKIP non-2D tensor {key} shape={tuple(tensor.shape)}")
            out_sd[key] = tensor
            continue

        base_key = key[:-len(".weight")] if key.endswith(".weight") else key
        if args.precision == "int8":
            err = _round_trip_check_int8(tensor)
            q, s = quantize_int8_symmetric_per_channel(tensor)
            out_sd[f"{base_key}.q_weight"] = q
            out_sd[f"{base_key}.scales"]   = s
        else:  # int4
            if tensor.shape[1] % args.group_size != 0:
                raise SystemExit(
                    f"{key}: in_features={tensor.shape[1]} not divisible by "
                    f"group_size={args.group_size}. Use a divisible group_size "
                    f"or exclude this tensor."
                )
            err = _round_trip_check_int4(tensor, args.group_size)
            q, s = quantize_int4_symmetric_per_group(tensor, args.group_size)
            out_sd[f"{base_key}.q_weight_packed"] = q
            out_sd[f"{base_key}.scales"]          = s

        max_error = max(max_error, err)
        n_quantized += 1
        level = "    " if err < args.rtol else "WARN"
        print(f"[quantize] {level} {key}  shape={tuple(tensor.shape)}  "
              f"round_trip_max_abs_err={err:.4e}")
        if err > args.rtol and args.strict:
            raise SystemExit(f"Round-trip error {err:.4e} exceeds rtol {args.rtol:.4e} (strict mode)")

    print(f"[quantize] {n_quantized} tensors quantized; worst round-trip err = {max_error:.4e}")
    save_file(out_sd, str(out_path), metadata=metadata)
    mb = sum(t.numel() * t.element_size() for t in out_sd.values()) / 1e6
    print(f"[quantize] wrote {out_path}  ({mb:.1f} MB)")


if __name__ == "__main__":
    main()
