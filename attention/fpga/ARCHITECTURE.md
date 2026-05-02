# FPGA Attention Kernel — Architecture

## 1. What the kernel computes

A single transformer attention layer's forward pass, given already-projected
Q, K, V tensors:

```
inputs (quantized):
    Q       shape (H_q,  S, D)   ap_int<8>   (or ap_int<4> for W4A4)
    K       shape (H_kv, S, D)   ap_int<8>
    V       shape (H_kv, S, D)   ap_int<8>
    q_scale scalar, float        combined rescale = scale_Q * scale_K / sqrt(D)
    v_scale scalar, float        rescale for V dequant

outputs:
    O       shape (H_q,  S, D)   half  (FP16)
```

Math performed per head:

```
scores[i][j] = (Q[i, :] · K[j, :]) * q_scale   , if j <= i  else  -inf   (causal mask)
P[i][j]      = softmax_row_j(scores[i])         (FP32 internally)
O[i][:]     += P[i][j] * (V[j, :] * v_scale)    summed over j
```

The compute is **W8A8** on the QK^T and PV matmuls (INT8 × INT8 → INT32
accumulator → dequantize to FP32 for softmax → re-quantize PK^T output
for PV), and FP32 for the softmax. Output is in FP16 for easy comparison
with the Python reference (which runs in FP32 natively).

## 2. Tiling strategy

**FlashAttention-style online softmax** — no S×S scores matrix ever
materialized. At `S = 1024` the full scores matrix would be 4 MB (FP32),
fits in on-chip BRAM but wastes bandwidth; at `S = 2048` it doesn't fit
at all. Online softmax scales to any seq_len.

Block sizes:

- `BQ` (query block): 64 rows of Q processed together
- `BK` (key/value block): 64 rows of K, V streamed through
- `D` (head_dim): 128 (unrolled in the inner MAC loop)

Outer loop structure:

```
for h_q in 0..H_q:
  for qb in 0..S step BQ:
    load Q_tile[BQ, D] into on-chip BRAM  (once per q-block)
    init m[BQ] = -inf, l[BQ] = 0, O_tile[BQ, D] = 0
    for kb in 0..S step BK:
      if kb > qb + BQ: continue          # causal skip
      load K_tile[BK, D], V_tile[BK, D]   # streaming from HBM
      compute scores[BQ, BK] = Q_tile @ K_tile^T in INT32
      dequantize scores to FP32, apply scale, apply causal mask
      update m[i], l[i], O_tile[i, :] via online softmax
    normalize O_tile[i, :] /= l[i]
    cast O_tile to FP16 and write back to HBM
```

The inner MAC on `scores = Q_tile @ K_tile^T` is the hot loop and maps
directly to DSP48E2s via `#pragma HLS UNROLL` on the D dimension.

## 3. On-chip memory budget (U280)

Available per the exact target spec (`xcu280-fsvh2892-2L-e`, Vitis 2023.2,
platform `xilinx_u280_gen3x16_xdma_base_1`): **8.86 MB BRAM + 33.75 MB URAM =
~42.6 MB on-chip SRAM** across 3 SLRs. Off-chip: 8 GB HBM2 @ 460 GB/s
(32 pseudo-channels) + 32 GB DDR4 @ 38 GB/s, PCIe Gen4 x8.

Per-kernel usage at `BQ = BK = 64, D = 128`:

- `Q_tile[64, 128]` INT8 = 8 KB → fits in ~4 BRAM
- `K_tile[64, 128]` INT8 = 8 KB → 4 BRAM
- `V_tile[64, 128]` INT8 = 8 KB → 4 BRAM
- `scores[64, 64]` INT32 = 16 KB → 4 BRAM (reusable, one live at a time)
- `O_tile[64, 128]` FP32 = 32 KB → 8 BRAM
- `m[64], l[64]` FP32 = 512 B each → 1 BRAM

Total per-kernel: ~30 BRAM + some LUTRAM for small arrays. Leaves lots
of headroom for replicating compute units if we want to parallelize over
heads later.

## 4. Numeric flow (this is where bugs hide)

Walk through one `scores[i][j]` computation end-to-end, staying explicit
about every cast:

```c++
// 1. Integer MAC — INT8 × INT8 → INT32 on DSP48E2
ap_int<32> acc = 0;
for (int k = 0; k < D; k++) {
    acc += (ap_int<32>)Q_tile[i][k] * (ap_int<32>)K_tile[j][k];
}
// acc ∈ [-D · 127^2, D · 127^2] for INT8, fits in INT32 (D=128 → max ~2M)

// 2. Apply combined scale (Q_scale * K_scale / sqrt(D))
float scaled = (float)acc * q_scale;

// 3. Causal mask
if (j > i + qb_offset) scaled = -1.0e38f;

// 4. Store to scores tile (FP32)
scores[i][j] = scaled;
```

The softmax and online-update step runs on FP32 `scores` and maintains
FP32 state `m[i], l[i], O_tile[i, :]`. Cost in area: ~3000 extra LUTs
per query row (for the `expf` approximation — we use a 64-entry LUT +
linear interpolation, not a full CORDIC).

For the **PV matmul**, we re-quantize the row of P = softmax(scores) to
INT8 dynamically per-row (compute max-abs of that row, scale, quantize),
so it can multiply against INT8 V on the DSPs. Dequantize the INT32
accumulator back to FP32 and add to O_tile.

This is the technique TensorRT-LLM's INT8 attention kernel uses (called
"per-row dynamic activation quantization" in the FasterTransformer docs).
It's the reason real INT8 attention is possible on INT8-only Tensor
Cores / DSPs — you don't skip the quantization step, you just do it cheaply.

## 5. DSP packing (optimization — not required for initial submission)

For the INT8 kernel, **one DSP48E2 can do two INT8 × INT8 MACs per cycle**
via the WP486 packing technique: interleave two 8-bit multiplicands in
the DSP's 27-bit input and recover both products from the 48-bit
accumulator by bit-shifting and extracting the high/low halves.

For INT4 (W4A4), **one DSP48E2 can do four INT4 × INT4 MACs per cycle**
via the WP487 extension.

The starter kernel here does **one MAC per DSP** — simpler, still
synthesizes cleanly, and hits ~40-60% of the packed peak. Packing is a
~1-day optimization on top of a working kernel; add it after the initial
numbers are in. Xilinx publishes reference packing code in their
xilinx_neural_network repo.

U280 kernel-clock targets (per the platform spec): **300 MHz baseline**,
**450 MHz stretch**, **500 MHz aspirational**. Effective INT8 peak at each
DSP-packing level (MAC = 2 ops; multiplying by 2 for the MAC→ops convention):

| DSPs used | MACs/DSP | 300 MHz | 450 MHz | 500 MHz |
|---|---|---|---|---|
| 9024 unpacked | 1 | 5.4 TOPS | 8.1 TOPS | 9.0 TOPS |
| 9024 WP486 packed | 2 | 10.8 TOPS | 16.2 TOPS | 18.0 TOPS |
| 9024 SIMD + WP486 | 4 | 21.6 TOPS | 32.4 TOPS | 36.0 TOPS |
| 9024 full fancy | 5-6 | 27-33 | 40-49 | **~49 TOPS** |

U280's published peak INT8 (~49 TOPS) assumes the full-fancy tier. A
"disciplined-packing" practical target is 20-30 TOPS sustained — the
band this kernel should aim for after one optimization pass beyond the
unpacked starter code. INT4 (W4A4) doubles the MAC-per-DSP factor
because two INT4 multiplies fit where one INT8 did, giving a realistic
40-60 TOPS sustained band.

**The starter code in `src/attention_int8.cpp` uses 1 MAC/DSP** (unpacked)
for clarity. Once cosim passes, the recommended optimization sequence is:
(1) add WP486 packing for 2 MACs/DSP → 2× throughput; (2) add activation-
side SIMD packing for 4 MACs/DSP → another 2×. Each step is ~1 day of work
for an HLS-fluent engineer.

## 6. AXI interface design

Three 512-bit AXI4 master ports per input tensor (Q, K, V), one for
output O. Each AXI master bundles to a separate HBM pseudo-channel so
they read in parallel, giving ~4 × 19.2 GB/s = **~77 GB/s** of effective
DMA bandwidth into the kernel. That's enough for the compute-bound
regime at `S >= 512`. Shorter sequences are memory-bound even on an FPGA.

The scalar rescale factors (`q_scale`, `v_scale`) go through a
lightweight AXI-Lite register interface.

## 7. Extending to W4A4

Only the MAC changes:

```c++
// INT8
ap_int<8> q = Q_tile[i][k];
ap_int<8> k = K_tile[j][k];
acc += (ap_int<32>)q * (ap_int<32>)k;

// INT4
ap_int<4> q = Q_tile[i][k];
ap_int<4> k_val = K_tile[j][k];
acc += (ap_int<32>)q * (ap_int<32>)k_val;
```

The storage / BRAM layout changes (pack two INT4 per byte), and the DSP
packing factor doubles (4 MACs/DSP instead of 2). Everything else —
softmax, tiling, AXI interfaces — is identical.

## 8. What the paper gets out of this

- **A real synthesis-derived latency** at W8A8 and W4A4 on a published
  commercial FPGA (U280), for the same attention shapes the CPU/GPU
  benchmarks used.
- **A cosim-verified output match** to the Python reference within
  `atol = 5e-2`, so the "same inputs, same outputs" fairness contract
  holds at the attention-kernel level.
- **Clear DSP/BRAM utilization numbers** that a reviewer can sanity-check
  against the kernel's analytic FLOPs count.
- **The argument** that custom silicon bypasses the software-stack
  overhead our GPU measurements exposed: there's no Python dispatch, no
  dynamic activation scan, no kernel-selection minefield — the integer
  pipeline just runs at whatever Fmax the tool delivers.
