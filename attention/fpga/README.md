# FPGA Attention Kernel — HLS Starter Project

Target: AMD Alveo U280 (`xcu280-fsvh2892-2L-e`), UltraScale+, 9024 DSP48E2, 8 GB HBM2 @ ~460 GB/s.

Goal: fused attention kernel in Vitis HLS that mirrors what the GPU/CPU benchmarks measure (a single attention layer's forward pass), at W8A8 (primary) and W4A4 (secondary) precisions. The kernel is **cosim-validated** against a Python reference so the "same inputs produce the same outputs" fairness contract holds across all three platforms.

## Scope and non-goals

**In scope (3 days):**
- Fused attention kernel: Q, K, V (quantized) in → attention output (FP16) out.
- W8A8: INT8 activations × INT8 weights → INT32 accumulate → dequantize for softmax → INT8 × INT8 for PV → FP16 output.
- W4A4: same structure with `ap_int<4>` types and DSP packing (4 INT4 MACs per DSP48E2 via WP487 technique).
- Single-head at a time, iterate over heads. Batch = 1.
- Fixed (or compile-time-parametrized) seq_len. Default `S=1024`.
- Target `Fmax = 300 MHz`. Report post-P&R utilization + achieved Fmax.

**Out of scope (defer):**
- Q/K/V linear projections. The CPU/GPU benchmarks include these; we'll note the scope difference in the paper and extrapolate via the analytic FLOPs counter (`src/bench/roofline.py`).
- Dynamic seq_len at runtime (fixed at compile time for now).
- KV cache append / prefix caching — this is a pure prefill benchmark.
- Multi-head-parallel instantiation (one head at a time keeps the kernel simple; the outer loop serializes heads).

## Directory layout

```
fpga/
├── README.md                   this file
├── ARCHITECTURE.md             algorithm + dataflow + design decisions
├── src/
│   ├── attention_top.h         parameters (S, D, H_q, H_kv) + type aliases
│   ├── attention_int8.cpp      W8A8 kernel, primary target
│   └── attention_int4.cpp      W4A4 kernel, secondary (diff is ~30 lines from int8)
├── tb/
│   ├── tb_attention_int8.cpp   C testbench, reads .bin testvectors, compares output
│   └── tb_attention_int4.cpp
├── scripts/
│   ├── dump_testvectors.py     Python: generates Q/K/V/reference-output .bin files
│   ├── run_csim.tcl            Vitis HLS C-simulation
│   ├── run_cosim.tcl           Vitis HLS RTL cosim + cycle count
│   ├── run_synth.tcl           synthesis + report generation for xcu280
│   └── parse_reports.py        scrape csynth.rpt → results/<model>_fpga_u280_<p>.jsonl
├── testvectors/                populated by dump_testvectors.py
└── reports/                    populated by synthesis
```

## Step-by-step workflow

### 0. Prerequisites on the synthesis machine

- Vitis HLS 2023.2 or newer (earlier versions are missing some of the `hls::bfloat16` utilities — we don't use BF16 in the kernel, but the wrappers reference it).
- Python 3.10+ with `numpy` and `torch` + `safetensors` (only needed for `dump_testvectors.py` — the kernel itself has no Python dep).
- U280 board support package in Vivado (auto-present with Vitis Unified installation).

### 1. Generate testvectors

From the repo root:

```bash
cd fpga
# Default: synthetic Gaussian inputs at the default shape (S=1024, H_q=32, H_kv=1, D=128).
python scripts/dump_testvectors.py --precision int8 --seq-len 1024 --num-q-heads 32 --num-kv-heads 1

# Or use real weights from one of our extracted safetensors (optional):
python scripts/dump_testvectors.py --precision int8 \
    --model ../configs/starcoder_7b_mqa.yaml
```

This writes `testvectors/<precision>/{Q.bin, K.bin, V.bin, output_reference.bin, meta.json}`.

### 2. C-simulation (fast functional check)

```bash
cd fpga
vitis_hls -f scripts/run_csim.tcl
```

C-sim compiles the kernel with `g++` (no hardware generation) and runs the testbench. Expected: "TEST PASS" if the kernel's output matches the reference within `atol=5e-2`. Takes ~10 seconds. If it fails here, there's a numerical bug — don't proceed to synthesis.

### 3. RTL cosim (cycle-accurate simulation)

```bash
vitis_hls -f scripts/run_cosim.tcl
```

Cosim generates RTL from the C++, runs the same testbench through a cycle-accurate SystemC/RTL simulator, compares outputs bit-for-bit. **This is where cycle count is extracted** — it's the defensible "how fast does this really run" number.

Takes 10-30 min depending on seq_len. Output in `reports/cosim.rpt`.

### 4. Synthesis + P&R for U280

```bash
vitis_hls -f scripts/run_synth.tcl
```

Runs HLS synthesis (not full Vivado P&R — that's a separate step if you want bitstream, which we don't). Emits `reports/csynth.rpt` with:
- Fmax (estimated)
- DSP48E2 utilization
- BRAM / URAM utilization
- Latency in cycles

For a full post-P&R Fmax (tighter numbers), add a Vivado project stage — left as follow-up since we don't need bitstream.

### 5. Generate result JSONLs for the plotter

```bash
python scripts/parse_reports.py \
    --variant mha \
    --precision int8 \
    --csynth reports/csynth.rpt \
    --cosim reports/cosim.rpt \
    --out ../results/llama2_7b_mha_fpga_u280_int8.jsonl
```

Produces a JSONL row per measured shape in the same schema as the CPU/GPU JSONLs, so `scripts/plot_results.py` in the parent repo renders FPGA data alongside the rest.

### 6. Repeat for INT4

Same workflow, swap `int8` → `int4` in the commands. The two kernels are separate files but share most structure.

### 7. Repeat per variant

For MHA/GQA/MQA, change `NUM_KV_HEADS` in `src/attention_top.h` and re-synthesize. Each resynth is ~10 min on a modern synthesis host. Parameterize with a TCL variable if you want to batch: `vitis_hls -f scripts/run_synth.tcl -tclargs --num-kv-heads 8` (script reads the arg).

## Expected numbers (so you know when something's off)

Reference cell: `S=1024, H_q=32, H_kv=1, D=128` (StarCoder MQA), **attention
math only — no Q/K/V/O projections** (see "Scope and non-goals" above; our
CPU/GPU measurements include projections, so attention-core-only FPGA numbers
need to be compared against the GPU's projection-excluded portion via the
roofline counter in `src/bench/roofline.py`).

**Analytic work at this cell**: ~17 GFLOPs per attention call (mostly the
QK^T and PV matmuls; softmax is negligible).

Predicted latency at three optimization tiers:

| Tier | Fmax | INT8 MACs/DSP | Sustained TOPS | Predicted latency |
|---|---|---|---|---|
| Starter kernel (as-shipped) | 300 MHz | 1 (unpacked) | ~2-3 | **6-10 ms** |
| After WP486 packing | 450 MHz | 2 | ~8-12 | **1.5-3 ms** |
| After SIMD packing (disciplined) | 450-500 MHz | 4 | 20-30 | **0.6-1.2 ms** |

INT4 (W4A4) should be **~0.5× the INT8 cycle count** (DSPs do 2× more MACs
per cycle at INT4). If your friend hits the disciplined-packing INT4 tier,
expect ~0.3-0.7 ms at the reference cell.

**Utilization targets:**

- DSP48E2: 3000-5000 used (of 9024). Less → kernel isn't unrolling;
  more → packing was misconfigured.
- BRAM: 200-500 BRAM18 blocks (of 4032 = 2016×2 halves). URAM should be
  0-32 blocks for single-head streaming.
- Fmax: 270-310 MHz (tier 1), 420-460 MHz (tier 2/3).

**Sanity check the latency once csynth.rpt lands:** the starter kernel's
worst-case cycle count from `csynth.rpt` divided by Fmax (in MHz) × 1000
should equal one of the three tier values above within ±30 %. If it's 5×
off, something is structurally wrong — usually either no pipelining on the
inner MAC loop or BRAM port contention, both visible in the HLS report's
"Performance Estimates" section.

## Troubleshooting cheatsheet

**C-sim fails the atol check.** Almost always a scale/dequant bug in the kernel. Print intermediate `scores[0][0]` and compare to Python reference. `ARCHITECTURE.md §4` documents the exact numeric flow.

**HLS synthesis says "unable to pipeline inner loop".** Usually a memory-port conflict. Add `#pragma HLS ARRAY_PARTITION` on the offending BRAM, or restructure to load then compute rather than interleaving.

**DSP count is much higher than expected.** You probably forgot `#pragma HLS INLINE off` on a helper function and the compiler inlined everything. Check the "RESOURCE" pragma hints; you want DSP48E2 mapped explicitly for the INT8 MAC.

**Fmax below 200 MHz.** Timing-critical path is usually the softmax reduction. Add a pipeline register inside the `exp` LUT or split the max-reduction into log2(BK) stages.

**Cosim takes forever.** Reduce `S` in `attention_top.h` to 256 for a quick correctness check; re-enable 1024 for the paper numbers.

Once csim passes, send the C-sim log + the csynth.rpt summary and I'll spot-check before you commit to the paper numbers.
