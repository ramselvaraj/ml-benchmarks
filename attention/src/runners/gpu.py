"""GPU runner — PyTorch CUDA with integer-compute quantization paths.

Target: NVIDIA L40S (Ada / sm_89, 48 GB GDDR6).

Primary integer tracks (dispatch through torchao's CUTLASS-backed kernels):

    int8  -> W8A8: INT4-quantized activations disabled, uniform per-channel
             INT8 weights, dynamic per-token INT8 activations, compute on
             Ada's INT8 Tensor Cores. Genuine INT8 MMA, matches FPGA INT8
             DSP packing (INT8 × INT8 → INT32).
    int4  -> W4A8: uniform per-group (128) INT4 weights, dynamic INT8
             activations, compute on Ada's INT8 Tensor Cores (INT4 weights
             are dequantized to INT8 in the register file before MMA).
             Genuine INT8 MMA with INT4 weight storage. The compute-
             instruction bit-width is INT8 here; FPGA W4A4 uses strictly
             narrower compute (INT4 × INT4 → INT32) — this asymmetry is
             documented in METHODOLOGY.md.

Research-comparison tracks (kept for the paper's discussion of how
"INT4" means different things across the software stack):

    nf4          -> bitsandbytes NF4: non-uniform 16-entry BF16 codebook,
                    dequant-to-BF16, BF16 Tensor Core compute. NOT integer
                    compute. Documents the "INT4 storage, BF16 math" path
                    that most HuggingFace-ecosystem tools actually use.
    int4_torchao -> torchao int4_weight_only (W4A16): uniform INT4 weights,
                    BF16 activations, BF16 Tensor Core compute via the
                    tinygemm kernel (tuned for M=1 decode, slow at attention-
                    prefill shapes). Documents the kernel-selection problem.
    int8_bnb     -> bitsandbytes LLM.int8(): per-tensor INT8 + FP16 outlier
                    decomposition. Different scheme from torchao per-channel.

Full-native W4A4 (INT4 × INT4 MMA on Ada's INT4 Tensor Cores) is not
exposed by stable PyTorch/torchao/bnb and requires BitBlas or a hand-
written CUTLASS kernel; we attempted BitBlas and it did not deploy
cleanly in the target environment. FPGA covers the W4A4 track.
"""
from __future__ import annotations

from typing import Literal

import torch
import torch.nn as nn

from ..attention.base import AttentionModule

Precision = Literal[
    "fp16", "bf16", "fp32",
    "int4", "int4_torchao", "nf4",
    "int8", "int8_compiled", "int8_bnb", "int8_wo",
]

_DTYPE_MAP = {
    "fp16": torch.float16,
    "bf16": torch.bfloat16,
    "fp32": torch.float32,
}


def to_cuda(module: AttentionModule, precision: Precision = "bf16") -> AttentionModule:
    if not torch.cuda.is_available():
        raise RuntimeError("CUDA not available")

    if precision in _DTYPE_MAP:
        module.to(device="cuda", dtype=_DTYPE_MAP[precision])
    elif precision == "int4":
        # Primary INT4 track: W4A8 via torchao. Real integer compute
        # (INT8 Tensor Cores), INT4 weight storage (genuine 4-bit),
        # dynamic INT8 activations. INT4 weights are dequantized to INT8
        # inside the CUTLASS kernel at MMA-setup time.
        module.to(device="cuda", dtype=torch.bfloat16)
        _torchao_quantize_(module, scheme="w4a8")
    elif precision == "int4_torchao":
        # Research comparison: W4A16 (weight-only INT4, BF16 compute).
        # The tinygemm backend is tuned for M=1 decode; expect slow
        # throughput at attention-prefill shapes on Ada.
        module.to(device="cuda", dtype=torch.bfloat16)
        _torchao_quantize_(module, scheme="w4a16")
    elif precision == "nf4":
        # Research comparison: bnb NF4 codebook + BF16 compute. Fast at
        # prefill but not integer compute — good for the paper's
        # "what does INT4 actually mean" discussion.
        module.to(device="cuda", dtype=torch.bfloat16)
        _bnb_quantize_(module, precision="nf4")
    elif precision == "int8":
        # Primary INT8 track: W8A8 via torchao. Real INT8 MMA on Ada
        # Tensor Cores, uniform per-channel INT8 weights, dynamic INT8
        # activations. Matches FPGA INT8 DSP packing bit-for-bit on the
        # compute side.
        module.to(device="cuda", dtype=torch.bfloat16)
        _torchao_quantize_(module, scheme="w8a8")
    elif precision == "int8_compiled":
        # W8A8 + torch.compile reduce-overhead mode. Captures the forward
        # pass into a CUDA graph, fuses dispatch + dynamic quant + matmul
        # where possible, and eliminates per-call Python overhead. This is
        # the closest "commodity PyTorch" can get to a production inference
        # engine's INT8 path without writing a custom CUTLASS kernel. Use
        # to separate software-overhead effects from fundamental kernel cost.
        module.to(device="cuda", dtype=torch.bfloat16)
        _torchao_quantize_(module, scheme="w8a8")
        module = torch.compile(module, mode="reduce-overhead", fullgraph=False)
    elif precision == "int8_bnb":
        module.to(device="cuda", dtype=torch.bfloat16)
        _bnb_quantize_(module, precision="int8")
    elif precision == "int8_wo":
        # W8A16: INT8 weight storage, BF16 activations, BF16 Tensor Core
        # compute. Weight gets dequantized to BF16 inside the kernel right
        # before the matmul — no dynamic activation quantization, no INT8
        # compute. Used specifically to isolate the storage-precision
        # effect (vs BF16/nf4/int4_torchao which all also do BF16 compute).
        module.to(device="cuda", dtype=torch.bfloat16)
        _torchao_quantize_(module, scheme="w8a16")
    else:
        raise ValueError(f"Unknown precision {precision}")

    module.eval()
    for p in module.parameters():
        p.requires_grad_(False)
    return module


# -----------------------------------------------------------------------------
# torchao path — real integer MMA via CUTLASS
# -----------------------------------------------------------------------------

def _torchao_quantize_(module: nn.Module, scheme: str) -> None:
    """Dispatch to torchao quantization configs by scheme name.

        w8a8  -> int8_dynamic_activation_int8_weight
                 (INT8 weights + dynamic INT8 activations, INT8 Tensor Cores)
        w4a8  -> int8_dynamic_activation_int4_weight(group_size=128)
                 (INT4 weights + dynamic INT8 activations, INT8 Tensor Cores
                  with INT4→INT8 dequant at MMA setup)
        w4a16 -> int4_weight_only(group_size=128)
                 (INT4 weights + BF16 activations, BF16 Tensor Cores via
                  tinygemm — research-comparison only, not integer compute)
    """
    try:
        from torchao.quantization import quantize_
    except ImportError as e:
        raise RuntimeError(
            "torchao required for int4/int8 GPU runs. "
            "pip install 'torchao>=0.7,<0.9'"
        ) from e

    if scheme == "w8a8":
        from torchao.quantization import int8_dynamic_activation_int8_weight
        config = int8_dynamic_activation_int8_weight()
    elif scheme == "w4a8":
        from torchao.quantization import int8_dynamic_activation_int4_weight
        config = int8_dynamic_activation_int4_weight(group_size=128)
    elif scheme == "w4a16":
        from torchao.quantization import int4_weight_only
        config = int4_weight_only(group_size=128)
    elif scheme == "w8a16":
        from torchao.quantization import int8_weight_only
        config = int8_weight_only()
    else:
        raise ValueError(f"Unknown torchao scheme: {scheme}")

    # Filter to nn.Linear only so torchao doesn't accidentally touch
    # any nn.Embedding (e.g. StarCoder's wpe position-embedding table).
    def _only_linear(mod, fqn):
        return isinstance(mod, nn.Linear)

    quantize_(module, config, filter_fn=_only_linear)


# -----------------------------------------------------------------------------
# bitsandbytes path — non-uniform codebook (NF4) + LLM.int8() comparisons
# -----------------------------------------------------------------------------

def _bnb_quantize_(module: nn.Module, precision: str) -> None:
    """Swap Linears for bitsandbytes quantized equivalents.

        nf4   -> Linear4bit(quant_type='nf4')  non-uniform codebook, BF16 compute
        int8  -> Linear8bitLt                  LLM.int8() with outlier decomposition
    """
    try:
        import bitsandbytes as bnb
    except ImportError as e:
        raise RuntimeError("bitsandbytes required for nf4/int8_bnb GPU runs") from e

    for name, child in list(module.named_children()):
        if isinstance(child, nn.Linear):
            if precision == "nf4":
                new = bnb.nn.Linear4bit(
                    child.in_features, child.out_features,
                    bias=child.bias is not None, quant_type="nf4",
                )
                new.weight = bnb.nn.Params4bit(
                    child.weight.data, requires_grad=False, quant_type="nf4"
                )
            elif precision == "int8":
                new = bnb.nn.Linear8bitLt(
                    child.in_features, child.out_features,
                    bias=child.bias is not None, has_fp16_weights=False,
                )
                new.weight = bnb.nn.Int8Params(
                    child.weight.data, requires_grad=False, has_fp16_weights=False,
                )
            else:
                raise ValueError(precision)
            if child.bias is not None:
                new.bias = nn.Parameter(child.bias.data, requires_grad=False)
            new.to("cuda")
            setattr(module, name, new)
        else:
            _bnb_quantize_(child, precision)
