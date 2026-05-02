"""Generate Q/K/V/reference-output binary testvectors for the HLS kernel.

Writes under fpga/testvectors/<precision>/:
    Q.bin                  int8 or packed-int4 (little-nibble-first)
    K.bin                  same
    V.bin                  same
    output_reference.bin   FP16 bit-packed reference output
    meta.json              { q_scale, v_scale, shapes, precision, seed }

The reference output is computed in PyTorch at FP32 using the same
FlashAttention-style formula as the HLS kernel (tiled, online softmax,
causal mask), so C-sim and cosim can do a straight element-wise comparison.

Usage:
    # Synthetic Gaussian inputs (default — fastest, no HF access needed)
    python scripts/dump_testvectors.py --precision int8 --seq-len 1024 \\
        --num-q-heads 32 --num-kv-heads 32 --head-dim 128

    # INT4 variant
    python scripts/dump_testvectors.py --precision int4
"""
from __future__ import annotations

import argparse
import json
import math
import struct
from pathlib import Path

import numpy as np
import torch

HERE = Path(__file__).resolve().parent
FPGA_ROOT = HERE.parent
TV_DIR = FPGA_ROOT / "testvectors"


# -----------------------------------------------------------------------------
# Quantization helpers — mirror scripts/quantize_weights.py's convention so
# the FPGA HLS kernel's unpack routine reads exactly what we wrote.
# -----------------------------------------------------------------------------

def quantize_int8(x: torch.Tensor) -> tuple[np.ndarray, float]:
    """Symmetric per-tensor INT8. Returns (int8 array, scale) such that
    x ≈ int8_array * scale."""
    x = x.to(torch.float32).cpu()
    s = x.abs().max().item()
    scale = max(s / 127.0, 1e-8)
    q = torch.round(x / scale).clamp(-127, 127).to(torch.int8)
    return q.numpy(), scale


def quantize_int4_packed(x: torch.Tensor) -> tuple[np.ndarray, float]:
    """Symmetric per-tensor INT4, packed 2-per-byte (low nibble first)."""
    x = x.to(torch.float32).cpu()
    s = x.abs().max().item()
    scale = max(s / 7.0, 1e-8)
    q = torch.round(x / scale).clamp(-7, 7).to(torch.int8)
    flat = q.view(-1).numpy().astype(np.int8)
    assert flat.size % 2 == 0, "need even element count to pack 2-per-byte"
    lo = flat[0::2].astype(np.uint8) & 0x0F
    hi = flat[1::2].astype(np.uint8) & 0x0F
    packed = (lo | (hi << 4)).astype(np.uint8)
    return packed, scale


# -----------------------------------------------------------------------------
# Reference attention (FP32) — matches the HLS kernel's math exactly.
# -----------------------------------------------------------------------------

def reference_attention_fp32(
    Q: torch.Tensor,    # (H_q, S, D)  dequantized FP32
    K: torch.Tensor,    # (H_kv, S, D)
    V: torch.Tensor,    # (H_kv, S, D)
    q_per_kv: int,
) -> torch.Tensor:      # returns (H_q, S, D) FP32
    H_q, S, D = Q.shape
    out = torch.zeros_like(Q)
    scale = 1.0 / math.sqrt(D)
    # Causal mask
    mask = torch.full((S, S), float("-inf"))
    mask = torch.triu(mask, diagonal=1)
    for h_q in range(H_q):
        h_kv = h_q // q_per_kv
        scores = (Q[h_q] @ K[h_kv].T) * scale        # (S, S)
        scores = scores + mask                       # causal
        probs = torch.softmax(scores, dim=-1)         # (S, S)
        out[h_q] = probs @ V[h_kv]                    # (S, D)
    return out


# -----------------------------------------------------------------------------
# Driver
# -----------------------------------------------------------------------------

def main():
    p = argparse.ArgumentParser()
    p.add_argument("--precision", choices=["int8", "int4"], required=True)
    p.add_argument("--seq-len",       type=int, default=1024)
    p.add_argument("--num-q-heads",   type=int, default=32)
    p.add_argument("--num-kv-heads",  type=int, default=32)
    p.add_argument("--head-dim",      type=int, default=128)
    p.add_argument("--seed",          type=int, default=1234)
    p.add_argument("--model",         help="(optional) YAML under configs/; currently "
                                           "only used to set shape defaults.")
    args = p.parse_args()

    if args.model:
        import yaml
        with open(args.model) as f:
            cfg = yaml.safe_load(f)
        args.num_q_heads  = cfg["num_attention_heads"]
        args.num_kv_heads = cfg["num_key_value_heads"]
        args.head_dim     = cfg["head_dim"]
        print(f"[dump] using shape from {args.model}: "
              f"H_q={args.num_q_heads} H_kv={args.num_kv_heads} D={args.head_dim}")

    S   = args.seq_len
    H_q = args.num_q_heads
    H_kv = args.num_kv_heads
    D   = args.head_dim
    assert H_q % H_kv == 0, "H_q must be divisible by H_kv"
    q_per_kv = H_q // H_kv

    out_dir = TV_DIR / args.precision
    out_dir.mkdir(parents=True, exist_ok=True)

    g = torch.Generator().manual_seed(args.seed)
    Q_fp = torch.randn(H_q,  S, D, generator=g, dtype=torch.float32) * 0.30
    K_fp = torch.randn(H_kv, S, D, generator=g, dtype=torch.float32) * 0.30
    V_fp = torch.randn(H_kv, S, D, generator=g, dtype=torch.float32) * 0.30

    # -- Reference output in FP32, then cast to FP16 (what the HLS kernel emits) --
    O_fp32 = reference_attention_fp32(Q_fp, K_fp, V_fp, q_per_kv)
    O_fp16 = O_fp32.to(torch.float16)

    # -- Quantize inputs --
    if args.precision == "int8":
        Q_q, q_scale_x = quantize_int8(Q_fp)
        K_q, k_scale_x = quantize_int8(K_fp)
        V_q, v_scale   = quantize_int8(V_fp)
    else:   # int4
        Q_q, q_scale_x = quantize_int4_packed(Q_fp)
        K_q, k_scale_x = quantize_int4_packed(K_fp)
        V_q, v_scale   = quantize_int4_packed(V_fp)

    # Combined Q·K rescale expected by the kernel:
    #   scores_float = (q_int * k_int) * q_scale_x * k_scale_x / sqrt(D)
    q_combined = q_scale_x * k_scale_x / math.sqrt(D)

    # -- Write binaries --
    (out_dir / "Q.bin").write_bytes(Q_q.tobytes())
    (out_dir / "K.bin").write_bytes(K_q.tobytes())
    (out_dir / "V.bin").write_bytes(V_q.tobytes())

    # FP16 reference: raw bit-pattern little-endian
    ref_bytes = O_fp16.view(torch.uint8).numpy().tobytes()
    (out_dir / "output_reference.bin").write_bytes(ref_bytes)

    meta = {
        "precision":      args.precision,
        "seq_len":        S,
        "num_q_heads":    H_q,
        "num_kv_heads":   H_kv,
        "head_dim":       D,
        "q_scale_input":  q_scale_x,
        "k_scale_input":  k_scale_x,
        "v_scale":        v_scale,
        "q_scale":        q_combined,   # combined factor expected by kernel
        "seed":           args.seed,
        "packing":        ("low_nibble_first" if args.precision == "int4" else "none"),
    }
    (out_dir / "meta.json").write_text(json.dumps(meta, indent=2))

    q_bytes = Q_q.nbytes
    print(f"[dump] wrote testvectors/{args.precision}/")
    print(f"[dump]   Q.bin  {q_bytes/1024:.1f} KiB")
    print(f"[dump]   K.bin  {K_q.nbytes/1024:.1f} KiB")
    print(f"[dump]   V.bin  {V_q.nbytes/1024:.1f} KiB")
    print(f"[dump]   output_reference.bin  {len(ref_bytes)/1024:.1f} KiB")
    print(f"[dump]   meta.json  -> q_scale={q_combined:.6g}  v_scale={v_scale:.6g}")


if __name__ == "__main__":
    main()
