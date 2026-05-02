"""Per-platform peak compute and bandwidth tables.
Single source of truth used by run_bench.py to derive utilization_pct
and by plot_results.py to draw roofline ridges.

Compute peaks are quoted as **TFLOPs/s** (float tracks) or **TOPS** (integer
tracks). For the integer tracks, we report the raw MMA throughput at the
compute precision the kernel actually executes (e.g. INT8 TC for `int4`
on GPU because torchao W4A8 dequantizes to INT8 in-register before MMA).
"""
from __future__ import annotations


# (device, precision) -> peak compute, TFLOPs/s for floats / TOPS for ints
PLATFORM_PEAK_TOPS: dict[tuple[str, str], float] = {
    # Float precisions — compute precision == named precision.
    ("cpu",       "bf16"):           2.9e12,    # AVX-512 BF16, dual-socket EPYC 9354
    ("cuda",      "bf16"):         362.0e12,    # L40S Tensor Core BF16
    ("cuda",      "fp16"):         362.0e12,    # same TC peak
    ("cuda",      "fp32"):          90.5e12,    # CUDA-core FP32

    # Real-integer-compute precisions — kernel actually runs INT8/INT4 MMA.
    ("cpu",       "int8"):          23.0e12,    # AVX-512 VNNI, 32 cores, one socket
    ("cuda",      "int8"):         724.0e12,    # INT8 TC via torchao/CUTLASS
    ("cuda",      "int4"):         724.0e12,    # torchao W4A8 routes INT8 TC, NOT INT4 TC
    ("cuda",      "int8_compiled"): 724.0e12,
    ("cuda",      "int8_bnb"):     724.0e12,
    ("fpga_u280", "int8"):           5.4e12,    # 9024 DSP × 300 MHz × 1 MAC (unpacked starter)
    ("fpga_u280", "int4"):          10.8e12,    # WP487 4-MAC packing — for the optimized cell

    # Weight-only quantization: storage is INTn but MMA is BF16 (weights
    # dequant in-register before matmul). Compute peak == BF16 peak.
    ("cuda",      "nf4"):          362.0e12,    # bnb NF4 → BF16 compute
    ("cuda",      "int8_wo"):      362.0e12,    # torchao int8_weight_only → BF16 compute
    ("cuda",      "int4_torchao"): 362.0e12,    # torchao tinygemm → BF16 compute
}


# Device -> sustained DRAM bandwidth, GB/s. Used for the memory-bound
# branch of the roofline.
PLATFORM_BW_GBPS: dict[str, float] = {
    "cpu":       460,    # 12× DDR5-4800 per socket, single NUMA node used
    "cuda":      864,    # L40S GDDR6
    "fpga_u280": 460,    # U280 HBM2, 32 pseudo-channels
}


def peak_flops(device: str, precision: str) -> float | None:
    """Return device peak FLOPs/s (or TOPS) for this precision, or None
    if the cell isn't in our table (caller should report n/a)."""
    return PLATFORM_PEAK_TOPS.get((device, precision))


def peak_bandwidth_gbps(device: str) -> float | None:
    return PLATFORM_BW_GBPS.get(device)
