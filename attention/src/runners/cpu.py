"""CPU runner — PyTorch on CPU with oneDNN-fused SDPA, plus dynamic
INT8 quantization for the integer track.

Hardware-specific notes (target: dual AMD EPYC 9354, Zen 4 Genoa):

  * `lscpu` must show `avx512_bf16`  (present on Zen 4) — used by BF16 track.
  * `lscpu` must show `avx512_vnni`  (present on Zen 4) — used by INT8 track.
    VNNI gives 4 INT8 MACs per 128-bit lane via VPDPBUSD; PyTorch's
    dynamic quantization dispatches to it via oneDNN's `qlinear_dynamic`.
  * `avx512_fp16` is NOT present on Zen 4 (Intel-only); FP16 upcasts.
  * 2 NUMA nodes × 32 cores. Launch with
       OMP_NUM_THREADS=32 numactl --cpunodebind=0 --membind=0 ...
    for all CPU runs to avoid cross-socket noise.

INT4 on CPU is not wired — x86 has no native INT4 compute instruction;
emulating it through INT8 gains no throughput and loses accuracy.
Track C (INT4) is GPU + FPGA in this project.

INT8 precision scheme caveat:
  PyTorch's `quantize_dynamic` uses **per-tensor** symmetric INT8 for
  weights (one scale per linear layer). GPU and FPGA INT8 paths use
  **per-channel** symmetric INT8 (one scale per output channel).
  This is a documented scheme asymmetry — the CPU cell is slightly less
  precise than the per-channel reference but within `atol=5e-2`. The
  paper notes this explicitly rather than silently accepting divergence.
"""
from __future__ import annotations

import torch
import torch.nn as nn

from ..attention.base import AttentionModule

# Precisions accepted on CPU. Anything else fails fast in run_bench.py.
CPU_PRECISIONS = ("bf16", "fp32", "fp16", "int8")


def to_cpu(module: AttentionModule, dtype: torch.dtype = torch.bfloat16,
           precision: str = "bf16") -> AttentionModule:
    """
    Args:
        dtype:     Activation dtype for the float track. Ignored when
                   `precision == "int8"` (dynamic quant handles dtype).
        precision: String precision tag; drives INT8 dispatch branch.
    """
    if precision == "int8":
        return _to_cpu_int8(module)

    if dtype == torch.float16:
        import warnings
        warnings.warn(
            "Running FP16 on CPU. On AMD Zen 4 / pre-Sapphire-Rapids Intel this "
            "silently upcasts to FP32. Prefer BF16 on Zen 4."
        )
    module.to(device="cpu", dtype=dtype)
    module.eval()
    for p in module.parameters():
        p.requires_grad_(False)
    return module


def _to_cpu_int8(module: AttentionModule) -> AttentionModule:
    """PyTorch dynamic INT8 quantization for CPU.

    `quantize_dynamic(module, {nn.Linear}, dtype=torch.qint8)` replaces
    every nn.Linear with a `DynamicQuantizedLinear` that:
      - stores weights as per-tensor symmetric INT8,
      - quantizes activations per-call (dynamic),
      - dispatches the matmul to oneDNN's fbgemm/VNNI qlinear kernel.

    We move the module to CPU in FP32 first (the quantizer requires FP
    inputs; it won't accept BF16 source weights on all PyTorch versions).
    """
    module.to(device="cpu", dtype=torch.float32)
    module.eval()
    for p in module.parameters():
        p.requires_grad_(False)

    # Explicit engine selection — fbgemm is the x86-AVX512 backend
    # (what the EPYC 9354 target uses). qnnpack is the ARM backend.
    # We pick whichever the build supports; the paper target is fbgemm.
    available = set(torch.backends.quantized.supported_engines)
    for engine in ("fbgemm", "x86", "qnnpack", "onednn"):
        if engine in available:
            torch.backends.quantized.engine = engine
            break
    else:
        raise RuntimeError(
            f"No supported CPU quantization engine found. "
            f"Available: {available}"
        )

    quantized = torch.ao.quantization.quantize_dynamic(
        module,
        qconfig_spec={nn.Linear},
        dtype=torch.qint8,
        inplace=False,
    )
    return quantized
