"""Cross-platform quantization equivalence.

Two separate guarantees, each verified here:

1. **Quantizer self-consistency.** The quantizer in
   scripts/quantize_weights.py round-trips to within its own scheme's
   precision floor. Round-trip = quantize then dequantize; the max
   absolute error bounds the best any consumer of these packed weights
   can do. This is the tightest test we have and doesn't need torch.ao
   or torchao installed.

2. **Library-vs-reference equivalence.** When torchao (GPU path) is
   applied to the same source weights, the resulting dequantized tensor
   matches our reference dequantization within `atol`. Our FPGA HLS
   kernel will consume the same packed bytes, so transitively the FPGA
   output must match torchao GPU output for the same activations.

The test is skipped cleanly if torchao isn't installed — we still want
(1) to run everywhere, including in CI on a CPU-only box.
"""
from __future__ import annotations

import sys
from pathlib import Path

import pytest
import torch

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))

from scripts.quantize_weights import (
    quantize_int4_symmetric_per_group,
    quantize_int8_symmetric_per_channel,
    dequantize_int4,
    dequantize_int8,
)


# Tolerances for equivalence. INT8 can be tight because it's a single-
# scale linear mapping; INT4 needs more slack because the 7-bit sign-
# magnitude representation is coarser.
INT8_ATOL = 5e-3
INT4_ATOL = 5e-2


# -----------------------------------------------------------------------------
# Quantizer self-consistency — runs anywhere
# -----------------------------------------------------------------------------

@pytest.mark.parametrize("shape,seed", [
    ((4096, 4096), 0),
    ((4096, 4096), 1),
    ((1024, 4096), 2),
    ((4096, 1024), 3),
])
def test_int8_round_trip(shape, seed):
    """Quantize → dequantize should recover the weight within INT8 floor."""
    torch.manual_seed(seed)
    w = torch.randn(*shape) * 0.02    # LLM-attention-layer-ish scale
    q, s = quantize_int8_symmetric_per_channel(w)
    w_hat = dequantize_int8(q, s)
    err = (w - w_hat).abs().max().item()
    assert err < INT8_ATOL, f"INT8 round-trip max abs err {err:.4e} > {INT8_ATOL:.4e}"


@pytest.mark.parametrize("shape,seed", [
    ((4096, 4096), 0),
    ((4096, 4096), 1),
    ((1024, 4096), 2),
    ((4096, 4096), 3),
])
def test_int4_round_trip(shape, seed):
    torch.manual_seed(seed)
    w = torch.randn(*shape) * 0.02
    q, s = quantize_int4_symmetric_per_group(w, group_size=128)
    w_hat = dequantize_int4(q, s, group_size=128)
    err = (w - w_hat).abs().max().item()
    assert err < INT4_ATOL, f"INT4 round-trip max abs err {err:.4e} > {INT4_ATOL:.4e}"


def test_int4_packing_roundtrip_bit_exact():
    """The unpack(pack(x)) path must be bit-exact on the nibble values —
    any error here means the FPGA HLS kernel (which will do its own
    unpack) won't see what the GPU pipeline produced.
    """
    torch.manual_seed(0)
    w = torch.randn(256, 1024) * 0.02
    q_packed, _ = quantize_int4_symmetric_per_group(w, group_size=128)

    # Manually unpack and compare to the signed INT4 we produced pre-pack.
    low  = (q_packed & 0x0F).to(torch.int8)
    high = ((q_packed >> 4) & 0x0F).to(torch.int8)
    low  = torch.where(low  >= 8, low  - 16, low)
    high = torch.where(high >= 8, high - 16, high)

    # Redo quantization without packing to get the ground-truth signed ints.
    w32 = w.to(torch.float32)
    O, I = w.shape
    G = I // 128
    s_max = w32.view(O, G, 128).abs().amax(dim=-1).clamp_min(1e-8)
    scales = s_max / 7.0
    q_signed = torch.round(w32.view(O, G, 128) / scales[..., None]).clamp(-7, 7).view(O, I).to(torch.int8)

    assert torch.equal(low,  q_signed[:, 0::2])
    assert torch.equal(high, q_signed[:, 1::2])


# -----------------------------------------------------------------------------
# torchao GPU path matches our reference dequantization
# -----------------------------------------------------------------------------

_TORCHAO_AVAILABLE = True
try:
    import torchao  # noqa: F401
    from torchao.quantization import quantize_, int4_weight_only, int8_weight_only
except ImportError:
    _TORCHAO_AVAILABLE = False


@pytest.mark.skipif(not _TORCHAO_AVAILABLE, reason="torchao not installed")
@pytest.mark.skipif(not torch.cuda.is_available(), reason="torchao INT8/INT4 path is CUDA-only")
def test_torchao_int8_matches_reference():
    """Feed the same weights into our quantizer and into torchao; their
    dequantized reconstructions should agree within INT8_ATOL."""
    torch.manual_seed(0)
    w = torch.randn(4096, 4096, device="cuda", dtype=torch.bfloat16) * 0.02

    # Reference path (what FPGA will consume)
    q_ref, s_ref = quantize_int8_symmetric_per_channel(w.float().cpu())
    w_ref = dequantize_int8(q_ref, s_ref).to("cuda", dtype=torch.bfloat16)

    # torchao path (what GPU will execute)
    import torch.nn as nn
    lin = nn.Linear(4096, 4096, bias=False, device="cuda", dtype=torch.bfloat16)
    lin.weight.data.copy_(w)
    quantize_(lin, int8_weight_only())
    # Access torchao's dequantized view of the weight.
    w_ao = lin.weight.dequantize().to(torch.bfloat16)

    diff = (w_ref - w_ao).abs().max().item()
    assert diff < INT8_ATOL, (
        f"torchao INT8 dequant differs from reference by {diff:.4e}. "
        f"Either torchao changed its quantization scheme or our reference is wrong."
    )


@pytest.mark.skipif(not _TORCHAO_AVAILABLE, reason="torchao not installed")
@pytest.mark.skipif(not torch.cuda.is_available(), reason="torchao INT8/INT4 path is CUDA-only")
def test_torchao_int4_matches_reference():
    torch.manual_seed(0)
    w = torch.randn(4096, 4096, device="cuda", dtype=torch.bfloat16) * 0.02

    q_ref, s_ref = quantize_int4_symmetric_per_group(w.float().cpu(), group_size=128)
    w_ref = dequantize_int4(q_ref, s_ref, group_size=128).to("cuda", dtype=torch.bfloat16)

    import torch.nn as nn
    lin = nn.Linear(4096, 4096, bias=False, device="cuda", dtype=torch.bfloat16)
    lin.weight.data.copy_(w)
    quantize_(lin, int4_weight_only(group_size=128))
    w_ao = lin.weight.dequantize().to(torch.bfloat16)

    diff = (w_ref - w_ao).abs().max().item()
    assert diff < INT4_ATOL, (
        f"torchao INT4 dequant differs from reference by {diff:.4e}. "
        f"Likely causes: torchao uses asymmetric quant, different group_size, "
        f"or different rounding mode. Inspect both q_weight tensors."
    )
