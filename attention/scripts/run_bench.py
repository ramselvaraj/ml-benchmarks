"""Main benchmark driver.

Usage:
    # smoke test on either device with random weights
    python scripts/run_bench.py --model llama2_7b_mha --device cpu  --dry-run --seq 256
    python scripts/run_bench.py --model llama2_7b_mha --device cuda --dry-run

    # real run after extract_weights.py has produced the .safetensors
    python scripts/run_bench.py --config configs/llama2_7b_mha.yaml \\
        --device cuda --precision bf16

CPU runs must be launched via numactl, e.g.
    OMP_NUM_THREADS=32 numactl --cpunodebind=0 --membind=0 \\
        python scripts/run_bench.py --config configs/llama2_7b_mha.yaml \\
        --device cpu --precision bf16
...otherwise cross-socket traffic will silently poison the numbers.
"""
from __future__ import annotations

import argparse
import json
import os
import platform
import sys
import time
from pathlib import Path

import torch
import yaml

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))

from src.attention import REGISTRY
from src.attention._impl import set_sdpa_backend
from src.attention.base import AttentionConfig
from src.bench.memory import kv_cache_bytes, track_peak, weights_bytes
from src.bench.peaks import peak_flops
from src.bench.power import PowerSampler
from src.bench.roofline import attention_flops_bytes
from src.bench.timing import time_callable
from src.inputs.generators import make_inputs
from src.runners.cpu import CPU_PRECISIONS, to_cpu
from src.runners.gpu import to_cuda
from src.utils.seeding import seed_everything


_ACTIVATION_DTYPE = {
    "fp16": torch.float16,
    "bf16": torch.bfloat16,
    "fp32": torch.float32,
    # For quantized paths, activations flow into the wrapper as BF16.
    # torchao's dynamic-activation configs then re-quantize per-call
    # to the target integer dtype inside CUTLASS. CPU INT8 requires
    # FP32 activations — that override happens in main().
    "int4":          torch.bfloat16,   # GPU: W4A8 via torchao (INT4 weight + INT8 activation, INT8 TC MMA)
    "int4_torchao":  torch.bfloat16,   # GPU: W4A16 via torchao (research-comparison, slow tinygemm)
    "nf4":           torch.bfloat16,   # GPU: bnb NF4 (codebook + BF16 compute, research-comparison)
    "int8":          torch.bfloat16,   # GPU: W8A8 via torchao (INT8 TC); CPU override: FP32
    "int8_compiled": torch.bfloat16,   # GPU: W8A8 + torch.compile reduce-overhead (removes dispatch/overhead)
    "int8_bnb":      torch.bfloat16,   # GPU: bnb LLM.int8() with outlier decomposition
    "int8_wo":       torch.bfloat16,   # GPU: W8A16 (INT8 storage, BF16 compute) — storage-only quant
}


def parse_args():
    p = argparse.ArgumentParser()
    p.add_argument("--config", help="YAML config under configs/")
    p.add_argument("--model",  help="Registry key (used with --dry-run)")
    p.add_argument("--device", choices=["cpu", "cuda"], required=True)
    p.add_argument("--precision", default="bf16",
                   choices=["fp16", "bf16", "fp32",
                            "int4", "int4_torchao", "nf4",
                            "int8", "int8_compiled", "int8_bnb", "int8_wo"])
    p.add_argument("--dry-run", action="store_true",
                   help="Skip weight loading, init randomly")
    p.add_argument("--seq",   type=int, help="Single seq_len (overrides sweep)")
    p.add_argument("--batch", type=int, help="Single batch (overrides sweep)")
    p.add_argument("--seed",  type=int, default=1234)
    # Output file is OVERWRITTEN by default (each run starts fresh). Pass
    # --append to add to an existing file (e.g. for cross-batch sweeps you
    # want to combine into one output). The historical default was append,
    # which silently doubled rows on re-runs and corrupted the plotter.
    p.add_argument("--append", action="store_true",
                   help="Append rows to the results JSONL instead of overwriting.")
    # Back-compat: accept the old --fresh flag as a no-op (it was the way
    # to opt INTO the new default behaviour).
    p.add_argument("--fresh", action="store_true",
                   help="(deprecated; overwrite is now the default)")
    p.add_argument("--sdpa-backend", default="flash",
                   choices=["flash", "efficient", "math", "auto"],
                   help="Pinned SDPA backend (recorded in output).")
    return p.parse_args()


def _validate_precision_for_device(device: str, precision: str) -> None:
    if device == "cpu" and precision not in CPU_PRECISIONS:
        raise SystemExit(
            f"precision={precision!r} is not supported on CPU (supported: "
            f"{CPU_PRECISIONS}). For CPU-INT4 you need llama.cpp or OpenVINO, "
            f"which this repo does not wire. See METHODOLOGY.md Track B."
        )


def load_config(args) -> AttentionConfig:
    if args.config:
        with open(args.config) as f:
            d = yaml.safe_load(f)
        if d.get("deprecated"):
            raise SystemExit(
                f"{args.config} is deprecated; see `replaced_by` field."
            )
        fields = {k: v for k, v in d.items()
                  if k in AttentionConfig.__dataclass_fields__}
        return AttentionConfig(**fields)
    # Dry-run defaults — kept in sync with configs/*.yaml.
    # 3 tier-1 (variant comparison) + 2 tier-2 (large-model SOTA).
    defaults = {
        # Tier 1 — 7B variant comparison.
        "llama2_7b_mha": dict(name="llama2_7b_mha", variant="MHA",
                              hidden_size=4096, num_attention_heads=32,
                              num_key_value_heads=32, head_dim=128,
                              max_position_embeddings=4096),
        "starcoder_7b_mqa": dict(name="starcoder_7b_mqa", variant="MQA",
                                 hidden_size=4096, num_attention_heads=32,
                                 num_key_value_heads=1, head_dim=128,
                                 max_position_embeddings=8192),
        "mistral_7b_gqa": dict(name="mistral_7b_gqa", variant="GQA",
                               hidden_size=4096, num_attention_heads=32,
                               num_key_value_heads=8, head_dim=128,
                               max_position_embeddings=8192),
        # Tier 2 — large-model SOTA face-off.
        "llama31_70b_gqa": dict(name="llama31_70b_gqa", variant="GQA",
                                hidden_size=8192, num_attention_heads=64,
                                num_key_value_heads=8, head_dim=128,
                                max_position_embeddings=131072,
                                rope_theta=500000.0),
        "deepseek_v2_mla": dict(name="deepseek_v2_mla", variant="MLA",
                                hidden_size=5120, num_attention_heads=128,
                                # MLA uses num_key_value_heads=num_attention_heads
                                # by convention (the "compression" is in the
                                # latent dim, not the head count).
                                num_key_value_heads=128, head_dim=192,
                                max_position_embeddings=163840,
                                rope_theta=10000.0,
                                q_lora_rank=1536, kv_lora_rank=512,
                                qk_nope_head_dim=128, qk_rope_head_dim=64,
                                v_head_dim=128),
    }
    if args.model not in defaults:
        raise SystemExit(f"--model must be one of {list(defaults)} or pass --config")
    return AttentionConfig(**defaults[args.model])


def build_module(cfg: AttentionConfig, args, dtype: torch.dtype):
    cls = REGISTRY[cfg.name]
    mod = cls(cfg)
    if args.dry_run:
        mod.random_init(dtype=dtype)
    else:
        if not cfg.weights_path:
            raise SystemExit("Config has no weights_path; run extract_weights.py first")
        mod.load_weights(cfg.weights_path)
    if args.device == "cuda":
        mod = to_cuda(mod, precision=args.precision)
    else:
        mod = to_cpu(mod, dtype=dtype, precision=args.precision)
    return mod


def _run_metadata(args, cfg: AttentionConfig) -> dict:
    """Small header row so a reader can distinguish between runs that
    differ only in environment (different PT version, different SDPA
    backend pinning, etc.)."""
    cuda_info = {}
    if torch.cuda.is_available():
        cuda_info = {
            "cuda_device": torch.cuda.get_device_name(0),
            "cuda_cc":     ".".join(map(str, torch.cuda.get_device_capability(0))),
        }
    return {
        "kind":             "meta",
        "model":            cfg.name,
        "variant":          cfg.variant,
        "device":           args.device,
        "precision":        args.precision,
        "phase":            "prefill",
        "seed":             args.seed,
        "sdpa_backend":     args.sdpa_backend,
        "torch_version":    torch.__version__,
        "platform":         platform.platform(),
        "python_version":   platform.python_version(),
        "omp_num_threads":  os.environ.get("OMP_NUM_THREADS"),
        # Provenance of inputs — currently always synthetic Gaussian
        # hidden_states from src/inputs/generators.py:make_inputs(seed=...).
        # Attention-kernel timing is invariant to input distribution at
        # our measurement granularity, so we don't tokenize a real corpus.
        "input_source":     "synthetic_gaussian",
        "input_seed":       args.seed,
        **cuda_info,
    }


def main():
    args = parse_args()
    _validate_precision_for_device(args.device, args.precision)
    seed_everything(args.seed)
    set_sdpa_backend(args.sdpa_backend)

    cfg = load_config(args)
    dtype = _ACTIVATION_DTYPE[args.precision]
    # CPU dynamic INT8 is a PyTorch-specific combination: the
    # DynamicQuantizedLinear op re-quantizes activations every call and
    # only accepts FP32 inputs. Override the activation dtype here so
    # make_inputs produces the right thing.
    if args.device == "cpu" and args.precision == "int8":
        dtype = torch.float32

    mod = build_module(cfg, args, dtype)
    w_bytes = weights_bytes(mod)

    seqs    = [args.seq]   if args.seq   else cfg.sweeps.get("seq_lens", [1024])
    batches = [args.batch] if args.batch else cfg.sweeps.get("batches",  [1])
    warmup  = cfg.warmup
    iters   = cfg.iters
    # OOM safety: skip any (B, S) cell whose B*S exceeds this cap. The cap
    # is per-config (see configs/<model>.yaml `sweeps.max_bs_product`); it
    # exists because tier-2 70B activation footprint at B=32 S=8192 is
    # ~50 GB on a 48 GB L40S. Set to None / unlimited if absent.
    max_bs_product = cfg.sweeps.get("max_bs_product")

    out_dir = ROOT / "results"
    out_dir.mkdir(exist_ok=True)
    out_path = out_dir / f"{cfg.name}_{args.device}_{args.precision}.jsonl"
    open_mode = "a" if args.append else "w"
    if args.append and out_path.exists():
        print(f"[run_bench] APPENDING to existing {out_path}")
    elif out_path.exists():
        print(f"[run_bench] OVERWRITING existing {out_path} "
              f"(pass --append to keep prior rows)")

    with open(out_path, open_mode) as out, torch.inference_mode():
        out.write(json.dumps(_run_metadata(args, cfg)) + "\n")
        out.flush()

        for B in batches:
            for S in seqs:
                if max_bs_product is not None and B * S > max_bs_product:
                    print(f"[{cfg.name}|{args.device}|{args.precision}] "
                          f"SKIP B={B} S={S} (B*S={B*S} > max_bs_product={max_bs_product})")
                    continue
                # ----- phase_staging: build inputs + move to device -------
                # Mirrors what a CPU/GPU inference engine would call "H2D".
                # On GPU we sync to make sure the copy is actually done; on
                # CPU the .to(device) is a no-op for tensors already on CPU
                # so this is mostly the randn() time.
                t0_stage = time.perf_counter_ns()
                inputs = make_inputs(B, S, cfg.hidden_size,
                                     dtype=dtype, device=args.device, seed=args.seed)
                if args.device == "cuda":
                    torch.cuda.synchronize()
                phase_staging_ms = (time.perf_counter_ns() - t0_stage) / 1e6

                def fwd():
                    return mod(inputs.hidden_states, inputs.position_ids, inputs.attention_mask)

                # ----- phase_compute: median over `iters` calls -----------
                # PowerSampler wraps the same window as the timing loop so
                # avg_power_w / energy_total_j are integrated over the
                # actual measurement period (not warmup, not setup).
                with track_peak(args.device) as get_peak, \
                     PowerSampler(device=args.device) as power:
                    stats = time_callable(fwd, device=args.device, warmup=warmup, iters=iters)
                    peak = get_peak()
                avg_power_w, energy_total_j = power.result()

                # ----- phase_output: D2H copy of one output tensor --------
                # Inference engines typically need to move the output back
                # to host before returning to user code; the standards doc
                # tracks this separately so we time it once.
                t0_out = time.perf_counter_ns()
                _ = fwd().detach().to("cpu")
                if args.device == "cuda":
                    torch.cuda.synchronize()
                phase_output_ms = (time.perf_counter_ns() - t0_out) / 1e6

                roof = attention_flops_bytes(
                    B, S, cfg.hidden_size, cfg.num_attention_heads,
                    cfg.num_key_value_heads, cfg.head_dim, dtype=dtype,
                    # MLA fields are None for non-MLA configs (default in
                    # AttentionConfig); the roofline routine dispatches on
                    # them. This is what stops DeepSeek-V2 from showing
                    # 124% utilization due to over-counting Q/K/V projections
                    # at full rank when they're actually low-rank.
                    q_lora_rank=cfg.q_lora_rank,
                    kv_lora_rank=cfg.kv_lora_rank,
                    qk_nope_head_dim=cfg.qk_nope_head_dim,
                    qk_rope_head_dim=cfg.qk_rope_head_dim,
                    v_head_dim=cfg.v_head_dim,
                )
                kv_b = kv_cache_bytes(B, S, cfg.num_key_value_heads, cfg.head_dim, dtype)

                # Derived perf metrics in the teammate-standard format.
                compute_s = stats.median_ms / 1000.0
                achieved_gflops = (roof.flops / compute_s) / 1e9
                pk = peak_flops(args.device, args.precision)
                util_pct = (achieved_gflops * 1e9 / pk) if pk else None

                row = {
                    "kind":              "sample",
                    "model":             cfg.name,
                    "variant":           cfg.variant,
                    "device":            args.device,
                    "precision":         args.precision,
                    "phase":             "prefill",
                    "batch":             B,
                    "seq_len":           S,
                    # Domain-specific throughput.
                    "tokens_per_s":      (B * S) / compute_s,
                    # Teammate-standard "samples/s" — one sample = one
                    # batched inference call processing B sequences.
                    "samples_per_s":     B / compute_s,
                    "weights_bytes":     w_bytes,
                    "peak_bytes":        peak,
                    "kv_cache_bytes":    kv_b,
                    # Phase decomposition (teammate-standard).
                    "phase_staging_ms":  phase_staging_ms,
                    "phase_compute_ms":  stats.median_ms,
                    "phase_output_ms":   phase_output_ms,
                    # Derived perf metrics.
                    "achieved_gflops":   achieved_gflops,
                    "peak_gflops":       (pk / 1e9) if pk else None,
                    "utilization_pct":   util_pct,
                    # Energy + average power for the timed window.
                    # NVML on GPU, RAPL on CPU; None if neither is available
                    # (e.g. pynvml not installed, or RAPL sysfs unreadable).
                    "energy_total_j":    energy_total_j,
                    "avg_power_w":       avg_power_w,
                    "tta_sec":           "N/A",       # inference benchmark
                    **stats.to_dict(),
                    **roof.to_dict(),
                }
                out.write(json.dumps(row) + "\n")
                out.flush()
                util_str = f"{util_pct*100:5.1f}% util" if util_pct is not None else "  (no peak)"
                print(f"[{cfg.name}|{args.device}|{args.precision}] "
                      f"B={B} S={S}  median={stats.median_ms:.3f} ms  "
                      f"throughput={row['tokens_per_s']:.1f} tok/s  "
                      f"{achieved_gflops:.0f} GFLOPs/s  {util_str}  "
                      f"AI={roof.arithmetic_intensity:.2f} FLOPs/byte")
                # Release this cell's activation tensors back to the
                # caching allocator so the next cell starts clean. Doesn't
                # reduce peak (set by the largest cell) but stops the
                # high-water mark from compounding cell-to-cell when the
                # sweep order is non-monotonic.
                del inputs
                if args.device == "cuda":
                    torch.cuda.empty_cache()

    print(f"\nResults {'appended to' if args.append else 'written to'} {out_path}")


if __name__ == "__main__":
    main()
