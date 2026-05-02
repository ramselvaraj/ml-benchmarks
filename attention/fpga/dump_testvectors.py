"""Generate Q/K/V/reference-output binaries for the HLS testbench.

Python 3.6 compatible (no `from __future__ import annotations`,
no PEP 585 generic types).

Defaults match the REDUCED-SIZE cosim config:
    NUM_Q_HEADS=1, Q_PER_KV=1 (so NUM_KV_HEADS=1),
    SEQ_LEN=128, HEAD_DIM=64.

The values you pass MUST match the constants in attention_top.h.
If they don't, the testbench will read garbage and csim will FAIL.

Writes under ./testvectors/int8/:
    Q.bin, K.bin, V.bin    int8 raw bytes
    output_reference.bin   FP16 bit pattern (little-endian)
    meta.json              { q_scale, v_scale, shapes }

Usage on Sol:
    cd ~/FPGA
    python3 dump_testvectors.py \
        --num-q-heads 1 --num-kv-heads 1 \
        --seq-len 128 --head-dim 64
"""

import argparse
import json
import math
from pathlib import Path

import numpy as np
import torch


def quantize_int8(x):
    """Symmetric per-tensor INT8. Returns (numpy int8 array, scale)."""
    x = x.to(torch.float32).cpu()
    s = x.abs().max().item()
    scale = max(s / 127.0, 1e-8)
    q = torch.round(x / scale).clamp(-127, 127).to(torch.int8)
    return q.numpy(), scale


def reference_attention_fp32(Q, K, V, q_per_kv):
    """Causal attention reference. Matches the kernel's math.

    The kernel multiplies INT8 dot products by q_scale (which already
    includes 1/sqrt(D)). Here we use dequantized FP32 tensors and apply
    1/sqrt(D) explicitly — mathematically equivalent.
    """
    H_q, S, D = Q.shape
    out = torch.zeros_like(Q)
    inv_sqrt_d = 1.0 / math.sqrt(D)
    mask = torch.triu(torch.full((S, S), float("-inf")), diagonal=1)
    for h_q in range(H_q):
        h_kv = h_q // q_per_kv
        scores = (Q[h_q] @ K[h_kv].T) * inv_sqrt_d
        scores = scores + mask
        probs = torch.softmax(scores, dim=-1)
        out[h_q] = probs @ V[h_kv]
    return out


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--num-q-heads",  type=int, default=1)
    p.add_argument("--num-kv-heads", type=int, default=1)
    p.add_argument("--seq-len",      type=int, default=128)
    p.add_argument("--head-dim",     type=int, default=64)
    p.add_argument("--seed",         type=int, default=1234)
    p.add_argument("--out-dir",      default="testvectors/int8")
    args = p.parse_args()

    H_q  = args.num_q_heads
    H_kv = args.num_kv_heads
    S    = args.seq_len
    D    = args.head_dim
    assert H_q % H_kv == 0, "NUM_Q_HEADS must be divisible by NUM_KV_HEADS"
    q_per_kv = H_q // H_kv

    out_dir = Path(args.out_dir)
    out_dir.mkdir(parents=True, exist_ok=True)

    g = torch.Generator().manual_seed(args.seed)
    Q_fp = torch.randn(H_q,  S, D, generator=g, dtype=torch.float32) * 0.30
    K_fp = torch.randn(H_kv, S, D, generator=g, dtype=torch.float32) * 0.30
    V_fp = torch.randn(H_kv, S, D, generator=g, dtype=torch.float32) * 0.30

    O_fp32 = reference_attention_fp32(Q_fp, K_fp, V_fp, q_per_kv)
    O_fp16 = O_fp32.to(torch.float16)

    Q_q, q_scale_x = quantize_int8(Q_fp)
    K_q, k_scale_x = quantize_int8(K_fp)
    V_q, v_scale   = quantize_int8(V_fp)

    # Combined Q.K rescale expected by the kernel:
    #   scores_float = (q_int * k_int) * q_scale * 1   (1/sqrt(D) baked in)
    q_combined = q_scale_x * k_scale_x / math.sqrt(D)

    (out_dir / "Q.bin").write_bytes(Q_q.tobytes())
    (out_dir / "K.bin").write_bytes(K_q.tobytes())
    (out_dir / "V.bin").write_bytes(V_q.tobytes())

    ref_bytes = O_fp16.numpy().view(np.uint8).tobytes()
    (out_dir / "output_reference.bin").write_bytes(ref_bytes)

    meta = {
        "num_q_heads":   H_q,
        "num_kv_heads":  H_kv,
        "q_per_kv":      q_per_kv,
        "seq_len":       S,
        "head_dim":      D,
        "q_scale":       q_combined,
        "v_scale":       v_scale,
        "q_scale_input": q_scale_x,
        "k_scale_input": k_scale_x,
        "seed":          args.seed,
    }
    (out_dir / "meta.json").write_text(json.dumps(meta, indent=2))

    print("[dump] wrote testvectors to {}/".format(out_dir))
    print("[dump]   Q.bin  {:.1f} KiB  shape ({},{},{})".format(Q_q.nbytes/1024, H_q, S, D))
    print("[dump]   K.bin  {:.1f} KiB  shape ({},{},{})".format(K_q.nbytes/1024, H_kv, S, D))
    print("[dump]   V.bin  {:.1f} KiB  shape ({},{},{})".format(V_q.nbytes/1024, H_kv, S, D))
    print("[dump]   output_reference.bin  {:.1f} KiB".format(len(ref_bytes)/1024))
    print("[dump] q_scale = {:.6g}   v_scale = {:.6g}".format(q_combined, v_scale))
    print("[dump] verify attention_top.h matches:")
    print("[dump]   NUM_Q_HEADS={}  NUM_KV_HEADS={}  Q_PER_KV={}  SEQ_LEN={}  HEAD_DIM={}".format(
        H_q, H_kv, q_per_kv, S, D))


if __name__ == "__main__":
    main()