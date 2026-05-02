"""Decode-path attention benchmark.

Complement to scripts/run_bench.py (which measures prefill). This script
maintains a synthetic KV cache and times incremental single-token forwards —
the workload that dominates real LLM serving at decode time and where the
MQA/GQA bandwidth advantage actually manifests in the data.

Per cell (model, device, precision):
  1. Build the attention module (random-init or from extracted weights).
  2. Pre-fill: run one prefill of the initial S_init tokens to populate
     the KV cache. Untimed.
  3. Decode loop: for each of `max_new_tokens` steps, generate a fresh
     random hidden_state of shape (1, 1, H), call forward_decode, append
     the returned (K, V) into the cache. Time each step.
  4. Record per-token latency stats (median / p50 / p95 / p99) over the
     post-warmup steps. Write to results/<model>_<dev>_<prec>_decode.jsonl.

Usage:
    python scripts/decode_bench.py --config configs/llama2_7b_mha.yaml \\
        --device cuda --precision bf16 --s-init 1024 --max-new-tokens 256

For the full sweep see scripts/decode_bench_all.sh (3 models × 5 cells).
"""
from __future__ import annotations

import argparse
import gc
import json
import os
import platform
import statistics
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
from src.bench.peaks import peak_flops
from src.bench.power import PowerSampler
from src.runners.cpu import CPU_PRECISIONS, to_cpu
from src.runners.gpu import to_cuda
from src.utils.seeding import seed_everything


_ACTIVATION_DTYPE = {
    "fp16": torch.float16,
    "bf16": torch.bfloat16,
    "fp32": torch.float32,
    "int4":          torch.bfloat16,
    "int4_torchao":  torch.bfloat16,
    "nf4":           torch.bfloat16,
    "int8":          torch.bfloat16,
    "int8_compiled": torch.bfloat16,
    "int8_bnb":      torch.bfloat16,
    "int8_wo":       torch.bfloat16,
}


def parse_args():
    p = argparse.ArgumentParser()
    p.add_argument("--config", help="YAML config under configs/")
    p.add_argument("--model",  help="Registry key (used with --dry-run)")
    p.add_argument("--device", choices=["cpu", "cuda"], required=True)
    p.add_argument("--precision", default="bf16",
                   choices=list(_ACTIVATION_DTYPE.keys()))
    p.add_argument("--dry-run", action="store_true",
                   help="Use random weights — skips weight loading.")
    p.add_argument("--batch",          type=int, default=1,
                   help="Batch size for the decode loop. Each step generates "
                        "one new token per batch element; total throughput is "
                        "batch / median_step_latency.")
    p.add_argument("--s-init",         type=int, default=1024,
                   help="Number of tokens to pre-fill the KV cache with.")
    p.add_argument("--max-new-tokens", type=int, default=256,
                   help="How many tokens to decode (timed loop).")
    p.add_argument("--warmup-tokens",  type=int, default=16,
                   help="Discarded from timing stats — let kernel cache settle.")
    p.add_argument("--repeats",        type=int, default=5,
                   help="Number of independent timed trials. Each trial "
                        "resets cache_len to post-prefill, runs --warmup-tokens "
                        "untimed steps, then times the remaining "
                        "(--max-new-tokens − --warmup-tokens) tokens. Reported "
                        "total_decode_ms is the mean across trials; stdev / "
                        "min / max are also emitted. Default 5 trades ~5× "
                        "wall time for 1/√5 ≈ 2.2× tighter measurement.")
    p.add_argument("--seed",   type=int, default=1234)
    # Output JSONL is OVERWRITTEN by default each run. --append keeps prior
    # rows. (Historical default was append, which silently corrupted plots.)
    p.add_argument("--append", action="store_true",
                   help="Append rows to the existing JSONL instead of overwriting.")
    p.add_argument("--fresh",  action="store_true",
                   help="(deprecated; overwrite is now the default)")
    p.add_argument("--sdpa-backend", default="flash",
                   choices=["flash", "efficient", "math", "auto"])
    p.add_argument("--cache-mode", default="inplace",
                   choices=["inplace", "cat"],
                   help="KV cache update strategy. 'inplace' pre-allocates the "
                        "cache at max_S and writes new K/V in place each step "
                        "(production behaviour, no allocator overhead). 'cat' "
                        "uses torch.cat to grow the cache each step (naive, "
                        "shows allocator-fragmentation cost at scale).")
    return p.parse_args()


def _validate_precision(device: str, precision: str) -> None:
    if device == "cpu" and precision not in CPU_PRECISIONS:
        raise SystemExit(
            f"precision={precision!r} is not supported on CPU "
            f"(supported: {CPU_PRECISIONS})."
        )


def load_config(args) -> AttentionConfig:
    if args.config:
        with open(args.config) as f:
            d = yaml.safe_load(f)
        if d.get("deprecated"):
            raise SystemExit(f"{args.config} is deprecated.")
        fields = {k: v for k, v in d.items()
                  if k in AttentionConfig.__dataclass_fields__}
        return AttentionConfig(**fields)
    defaults = {
        # Tier 1 — 7B variant comparison.
        "llama2_7b_mha":    dict(name="llama2_7b_mha",    variant="MHA",
                                 hidden_size=4096, num_attention_heads=32,
                                 num_key_value_heads=32, head_dim=128,
                                 max_position_embeddings=4096),
        "starcoder_7b_mqa": dict(name="starcoder_7b_mqa", variant="MQA",
                                 hidden_size=4096, num_attention_heads=32,
                                 num_key_value_heads=1,  head_dim=128,
                                 max_position_embeddings=8192),
        "mistral_7b_gqa":   dict(name="mistral_7b_gqa",   variant="GQA",
                                 hidden_size=4096, num_attention_heads=32,
                                 num_key_value_heads=8,  head_dim=128,
                                 max_position_embeddings=8192),
        # Tier 2 — large-model SOTA face-off.
        "llama31_70b_gqa":  dict(name="llama31_70b_gqa", variant="GQA",
                                 hidden_size=8192, num_attention_heads=64,
                                 num_key_value_heads=8, head_dim=128,
                                 max_position_embeddings=131072,
                                 rope_theta=500000.0),
        "deepseek_v2_mla":  dict(name="deepseek_v2_mla", variant="MLA",
                                 hidden_size=5120, num_attention_heads=128,
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


def build_module(cfg, args, dtype):
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


def _gen_hidden(B, S, H, dtype, device, seed):
    g = torch.Generator(device="cpu").manual_seed(seed)
    h = torch.randn(B, S, H, generator=g, dtype=torch.float32)
    return h.to(device=device, dtype=dtype)


def _timer(device: str):
    """Return (start, stop) callables that measure ms of GPU or CPU work."""
    if device.startswith("cuda") and torch.cuda.is_available():
        def start():
            ev = torch.cuda.Event(enable_timing=True)
            ev.record()
            return ev
        def stop(ev_start):
            ev_end = torch.cuda.Event(enable_timing=True)
            ev_end.record()
            torch.cuda.synchronize()
            return ev_start.elapsed_time(ev_end)
        return start, stop
    else:
        def start():
            return time.perf_counter_ns()
        def stop(t0):
            return (time.perf_counter_ns() - t0) / 1e6
        return start, stop


def main():
    args = parse_args()
    _validate_precision(args.device, args.precision)
    seed_everything(args.seed)
    set_sdpa_backend(args.sdpa_backend)

    cfg = load_config(args)
    dtype = _ACTIVATION_DTYPE[args.precision]
    if args.device == "cpu" and args.precision == "int8":
        dtype = torch.float32     # CPU dynamic quant requires FP32 activations

    mod = build_module(cfg, args, dtype)

    # OOM guard: max_bs_product caps B*max_S so the KV cache buffer fits.
    # For decode the limiting tensor is the in-place k_cache/v_cache of
    # shape (B, H_kv, max_S, D) × 2 (K and V). At Llama-3-70B GQA
    # (H_kv=8, D=128) BF16, B=1 max_S=2048 is 4 MB — trivial. The
    # constraint mostly matters for MHA models where H_kv = H_q.
    max_S = args.s_init + args.max_new_tokens
    bs_product = args.batch * max_S
    cap = cfg.sweeps.get("max_bs_product")
    if cap is not None and bs_product > cap:
        raise SystemExit(
            f"[decode] B*max_S={bs_product} > max_bs_product={cap} for {cfg.name}. "
            f"Reduce --batch, --s-init, or --max-new-tokens to stay safe."
        )

    # ------------------------------------------------------------------
    # Step 1: pre-fill the KV cache with S_init tokens (untimed).
    # We do this by simulating S_init individual forward_decode steps so
    # the cache builds incrementally to S_init. This is what real serving
    # systems do internally; for our purposes it just produces a ready
    # cache of the right shape and contents.
    # ------------------------------------------------------------------
    H_kv = cfg.num_key_value_heads
    D    = cfg.head_dim
    H    = cfg.hidden_size
    B    = args.batch

    print(f"[decode] cfg={cfg.name} dev={args.device} prec={args.precision} "
          f"B={B} S_init={args.s_init} new_tokens={args.max_new_tokens} "
          f"cache_mode={args.cache_mode}")

    # max_S already computed above for the OOM guard.

    # --- phase_staging: KV-cache warm-up via prefill ----------------------
    # In a real decode workload, this is the "first-token-after-prompt"
    # cost — the prompt-prefill that has to happen before any decode steps.
    # We measure it here so it can be reported separately in the CSV.
    t0_stage = time.perf_counter_ns()

    with torch.inference_mode():
        # Fast prefill: project the entire S_init prefix in one call.
        h_init = _gen_hidden(B, args.s_init, H, dtype, args.device, args.seed)
        pos_init = (torch.arange(args.s_init, device=args.device)
                         .unsqueeze(0).expand(B, -1))

        is_mla = cfg.variant == "MLA"

        if is_mla and args.cache_mode == "cat":
            raise SystemExit(
                "MLA models only support --cache-mode inplace. The latent KV "
                "cache (c_kv + K_R) is the whole point of MLA; cat-mode "
                "would defeat the comparison."
            )

        if args.cache_mode == "inplace":
            if is_mla:
                # MLA cache: c_kv (B, max_S, kv_lora_rank) and K_R (B, max_S,
                # qk_rope_head_dim). Total cache footprint per token is
                # (kv_lora_rank + qk_rope_head_dim) bytes_per_elem — much
                # smaller than full (H_kv * head_dim * 2) for non-MLA models.
                c_kv_cache = torch.empty(B, max_S, cfg.kv_lora_rank,
                                          dtype=dtype, device=args.device)
                k_r_cache  = torch.empty(B, max_S, cfg.qk_rope_head_dim,
                                          dtype=dtype, device=args.device)
                cache_len = mod.precompute_kv_into_buffer(
                    h_init, pos_init, c_kv_cache, k_r_cache)
                past_kv = None
                k_cache = v_cache = None
                print(f"[decode]   prefill done (inplace, MLA). "
                      f"cache_len = {cache_len}, "
                      f"c_kv buffer = {tuple(c_kv_cache.shape)}, "
                      f"k_r buffer = {tuple(k_r_cache.shape)}")
            else:
                # Pre-allocate cache buffers at the max sequence length we'll need.
                # No more allocations grow during the decode loop after this point.
                k_cache = torch.empty(B, H_kv, max_S, D, dtype=dtype, device=args.device)
                v_cache = torch.empty(B, H_kv, max_S, D, dtype=dtype, device=args.device)
                cache_len = mod.precompute_kv_into_buffer(h_init, pos_init, k_cache, v_cache)
                past_kv = None    # not used in inplace mode
                c_kv_cache = k_r_cache = None
                print(f"[decode]   prefill done (inplace). cache_len = {cache_len}, "
                      f"buffer = {k_cache.shape}")
        else:  # "cat" — naive growing-tensor decode (non-MLA only)
            past_k, past_v = mod.precompute_kv(h_init, pos_init)
            past_kv = (past_k, past_v)
            cache_len = None  # not used in cat mode
            k_cache = v_cache = None
            c_kv_cache = k_r_cache = None
            print(f"[decode]   prefill done (cat). K shape = {tuple(past_kv[0].shape)}")

        if args.device == "cuda":
            torch.cuda.synchronize()
        phase_staging_ms = (time.perf_counter_ns() - t0_stage) / 1e6

        # ------------------------------------------------------------------
        # Step 2: decode in two phases — an untimed warmup, then a single
        # end-to-end timed window over the remaining tokens. We do NOT
        # synchronize between steps anymore: kernel launches pipeline
        # naturally on GPU (which is what production decode does), and
        # the only sync we care about is the one at the end of the window
        # before we read the timer.
        #
        # Critical detail: hidden states for ALL decode steps are
        # pre-generated on the device BEFORE the timed window. The
        # original loop called `_gen_hidden(...)` per step, which does
        # CPU torch.randn (~milliseconds for B=16) + a host→device copy.
        # Including that in the timed window inflates per-step latency by
        # 30× over the actual forward cost. Real production decode reads
        # the next token's hidden state from a fast on-device embedding
        # lookup, not a per-call CPU randn — so our synthetic harness
        # shouldn't pretend to pay that cost. Pre-generating once is the
        # honest equivalent.
        # ------------------------------------------------------------------

        # Pre-generate all hidden states + position_ids for warmup + timed
        # window. Lives entirely on device; no CPU work in the loop body.
        all_h = _gen_hidden(B, args.max_new_tokens, H, dtype,
                            args.device, args.seed + 100_000)
        all_pos = (torch.arange(args.s_init,
                                 args.s_init + args.max_new_tokens,
                                 dtype=torch.long, device=args.device)
                        .unsqueeze(0).expand(B, -1).contiguous())

        # cat-mode bookkeeping: each trial needs to start from the post-
        # prefill past_kv state. inplace mode just resets cache_len; the
        # buffer contents past s_init get overwritten as decode runs.
        post_prefill_cache_len = cache_len if args.cache_mode == "inplace" else None
        post_prefill_past_kv   = past_kv   if args.cache_mode == "cat"     else None

        timed_tokens = args.max_new_tokens - args.warmup_tokens

        # --- Multi-trial measurement -------------------------------------
        # Each trial: reset cache state -> warmup steps (untimed) -> timed
        # window -> record total_decode_ms. Aggregate at the end.
        # Power sampling is per-trial; we average avg_power across trials
        # and sum energy_j for a representative full-window value.
        trial_times_ms: list[float] = []
        trial_powers_w: list[float] = []
        trial_energies_j: list[float] = []

        # Disable Python's cyclic garbage collector across all trials so
        # periodic GC sweeps don't get attributed to decode time.
        gc_was_enabled = gc.isenabled()
        gc.disable()

        last_out = None
        for trial in range(args.repeats):
            # Reset cache state to post-prefill for this trial.
            if args.cache_mode == "inplace":
                cache_len = post_prefill_cache_len
            else:
                past_kv = post_prefill_past_kv

            # --- Warmup (untimed) — settles JIT, allocator, kernel cache.
            for t in range(args.warmup_tokens):
                h_t = all_h[:, t:t+1, :]
                pos = all_pos[:, t:t+1]
                if args.cache_mode == "inplace":
                    if is_mla:
                        last_out, cache_len = mod.forward_decode_inplace(
                            h_t, pos, c_kv_cache, k_r_cache, cache_len)
                    else:
                        last_out, cache_len = mod.forward_decode_inplace(
                            h_t, pos, k_cache, v_cache, cache_len)
                else:
                    last_out, past_kv = mod.forward_decode(h_t, pos, past_kv)
            if args.device == "cuda":
                torch.cuda.synchronize()

            # --- Timed window — one start, one stop, no per-step sync ----
            with PowerSampler(device=args.device) as power:
                if args.device == "cuda":
                    start_event = torch.cuda.Event(enable_timing=True)
                    end_event   = torch.cuda.Event(enable_timing=True)
                    start_event.record()
                else:
                    t_start_ns = time.perf_counter_ns()

                for t in range(args.warmup_tokens, args.max_new_tokens):
                    h_t = all_h[:, t:t+1, :]
                    pos = all_pos[:, t:t+1]
                    if args.cache_mode == "inplace":
                        if is_mla:
                            last_out, cache_len = mod.forward_decode_inplace(
                                h_t, pos, c_kv_cache, k_r_cache, cache_len)
                        else:
                            last_out, cache_len = mod.forward_decode_inplace(
                                h_t, pos, k_cache, v_cache, cache_len)
                    else:
                        last_out, past_kv = mod.forward_decode(h_t, pos, past_kv)

                if args.device == "cuda":
                    end_event.record()
                    torch.cuda.synchronize()
                    trial_ms = start_event.elapsed_time(end_event)
                else:
                    trial_ms = (time.perf_counter_ns() - t_start_ns) / 1e6

            avg_w, energy_j = power.result()
            trial_times_ms.append(trial_ms)
            if avg_w     is not None: trial_powers_w.append(avg_w)
            if energy_j  is not None: trial_energies_j.append(energy_j)

            print(f"[decode]   trial {trial+1}/{args.repeats}: "
                  f"{trial_ms:.2f} ms ({trial_ms/timed_tokens:.3f} ms/token)")

        # Re-enable GC and collect explicitly now that timing is over.
        if gc_was_enabled:
            gc.enable()
        gc.collect()

        # Aggregate trial stats.
        total_decode_ms       = statistics.fmean(trial_times_ms)
        total_decode_ms_stdev = statistics.pstdev(trial_times_ms) if len(trial_times_ms) > 1 else 0.0
        total_decode_ms_min   = min(trial_times_ms)
        total_decode_ms_max   = max(trial_times_ms)
        total_decode_ms_cv_pct = (
            100.0 * total_decode_ms_stdev / total_decode_ms if total_decode_ms > 0 else 0.0
        )
        avg_power_w   = (statistics.fmean(trial_powers_w)   if trial_powers_w   else None)
        energy_total_j = (sum(trial_energies_j)              if trial_energies_j else None)

    # --- phase_output: D2H of the final-token output --------------------
    t0_out = time.perf_counter_ns()
    if last_out is not None:
        _ = last_out.detach().to("cpu")
        if args.device == "cuda":
            torch.cuda.synchronize()
    phase_output_ms = (time.perf_counter_ns() - t0_out) / 1e6

    # End-to-end derived metrics. timed_tokens = how many tokens we actually
    # measured (max_new_tokens minus warmup). avg_per_token_ms is the mean
    # over that window — the only per-token number we need.
    avg_per_token_ms = total_decode_ms / max(1, timed_tokens)

    # KV cache scales with batch — it stores a separate K, V (or c_kv + K_R
    # for MLA) for each sequence.
    if cfg.variant == "MLA":
        # MLA cache: c_kv (lora_rank) + K_R (qk_rope_head_dim) per token.
        per_token_dim = cfg.kv_lora_rank + cfg.qk_rope_head_dim
        final_kv_size_bytes = (
            B * (args.s_init + args.max_new_tokens) * per_token_dim * dtype.itemsize
        )
    else:
        final_kv_size_bytes = (
            2 * B * (args.s_init + args.max_new_tokens) * H_kv * D * dtype.itemsize
        )

    out_dir = ROOT / "results"
    out_dir.mkdir(exist_ok=True)
    out_path = out_dir / f"{cfg.name}_{args.device}_{args.precision}_decode.jsonl"
    open_mode = "a" if args.append else "w"
    if args.append and out_path.exists():
        print(f"[decode] APPENDING to existing {out_path}")
    elif out_path.exists():
        print(f"[decode] OVERWRITING existing {out_path} "
              f"(pass --append to keep prior rows)")

    with open(out_path, open_mode) as out:
        meta = {
            "kind":              "meta_decode",
            "model":             cfg.name,
            "variant":           cfg.variant,
            "device":            args.device,
            "precision":         args.precision,
            "phase":             "decode",
            "batch":             B,
            "s_init":            args.s_init,
            "max_new_tokens":    args.max_new_tokens,
            "warmup_tokens":     args.warmup_tokens,
            "cache_mode":        args.cache_mode,
            "torch_version":     torch.__version__,
            "platform":          platform.platform(),
            "python_version":    platform.python_version(),
            "omp_num_threads":   os.environ.get("OMP_NUM_THREADS"),
            "sdpa_backend":      args.sdpa_backend,
            "seed":              args.seed,
            # Provenance — same Gaussian generator as prefill (seed-deterministic).
            "input_source":      "synthetic_gaussian",
            "input_seed":        args.seed,
        }
        if torch.cuda.is_available():
            meta["cuda_device"] = torch.cuda.get_device_name(0)
            meta["cuda_cc"]     = ".".join(map(str, torch.cuda.get_device_capability(0)))
        out.write(json.dumps(meta) + "\n")

        # ---- Per-step FLOPs (decode): projections + Q×K^T over cache + A×V ----
        # Q, K, V, O projections are constant per step. Attention math grows
        # linearly with cache length. We use the *average* cache length over
        # the timed window for the achieved-GFLOPs estimate.
        H_q   = cfg.num_attention_heads
        D_h   = cfg.head_dim
        H_dim = cfg.hidden_size
        avg_cache_len = (args.s_init + args.warmup_tokens
                         + (args.max_new_tokens - args.warmup_tokens) / 2)

        if cfg.variant == "MLA":
            # MLA decode FLOPs (absorbed path — what forward_decode_inplace
            # actually does). Mirrors plot_results.py:_decode_flops_per_step_mla.
            qk_nope = cfg.qk_nope_head_dim
            qk_rope = cfg.qk_rope_head_dim
            qk_dim  = qk_nope + qk_rope
            d_v     = cfg.v_head_dim
            q_lora  = cfg.q_lora_rank
            kv_lora = cfg.kv_lora_rank
            if q_lora is not None:
                flops_q = 2 * B * (H_dim * q_lora + q_lora * H_q * qk_dim)
            else:
                flops_q = 2 * B * H_dim * H_q * qk_dim
            flops_kv      = 2 * B * H_dim * (kv_lora + qk_rope)
            flops_q_abs   = 2 * B * H_q * qk_nope * kv_lora
            flops_score_n = 2 * B * H_q * avg_cache_len * kv_lora
            flops_score_r = 2 * B * H_q * avg_cache_len * qk_rope
            flops_pv_lat  = 2 * B * H_q * avg_cache_len * kv_lora
            flops_v_abs   = 2 * B * H_q * kv_lora * d_v
            flops_o       = 2 * B * H_q * d_v * H_dim
            flops_per_step = (flops_q + flops_kv + flops_q_abs
                              + flops_score_n + flops_score_r
                              + flops_pv_lat + flops_v_abs + flops_o)
        else:
            # Standard MHA/MQA/GQA path.
            kv_dim = H_kv * D_h
            # Projections (per step): Q, O are H×H; K, V are H×kv_dim
            flops_proj = 2 * B * 1 * H_dim * H_dim * 2 + 2 * 2 * B * 1 * H_dim * kv_dim
            # Attention math, averaged over the warmup-stripped window:
            flops_attn = 2 * 2 * B * H_q * 1 * avg_cache_len * D_h
            flops_per_step = flops_proj + flops_attn

        # Achieved GFLOPs uses the average-per-step time (compute_s_per_step)
        # against the analytic per-step FLOPs. Same number you'd get from
        # (total_decode_flops / total_decode_time) by construction.
        compute_s_per_step = avg_per_token_ms / 1000.0
        achieved_gflops = (flops_per_step / compute_s_per_step) / 1e9
        pk = peak_flops(args.device, args.precision)
        util_pct = (achieved_gflops * 1e9 / pk) if pk else None

        # Total tokens emitted in the timed window (across the batch).
        total_tokens_generated = B * timed_tokens
        total_decode_s = total_decode_ms / 1000.0

        sample = {
            "kind":            "sample_decode",
            "model":           cfg.name,
            "variant":         cfg.variant,
            "device":          args.device,
            "precision":       args.precision,
            "phase":           "decode",
            "batch":           B,
            "s_init":          args.s_init,
            "tokens_decoded":  args.max_new_tokens,
            "warmup_tokens":   args.warmup_tokens,
            "timed_tokens":    timed_tokens,
            "cache_mode":      args.cache_mode,
            # ---- End-to-end decode timing — the headline numbers ----
            # total_decode_ms: wall time for the timed window (post-warmup).
            # avg_per_token_ms: total_decode_ms / timed_tokens — one number
            #   capturing "how long does the model take per generation step".
            # tokens_per_s: total tokens emitted (B * timed_tokens) per second
            #   over the timed window. This is the throughput a serving system
            #   would advertise for a B-way concurrent decode at this cache size.
            "total_decode_ms":   total_decode_ms,
            "avg_per_token_ms":  avg_per_token_ms,
            "tokens_per_s":      total_tokens_generated / total_decode_s,
            "samples_per_s":     B / (avg_per_token_ms / 1000.0),
            # ---- Multi-trial variability ----
            # repeats: how many timed trials we ran. >1 means the headline
            # numbers above are means; the stdev/min/max give you a noise
            # band so you don't read a single noisy run as a finding.
            # CV% = stdev / mean × 100 — a quick "is this stable" indicator.
            # CV < 5% is excellent, 5-15% is acceptable, >15% suggests the
            # GPU clock isn't locked or another workload is contending.
            "repeats":              args.repeats,
            "total_decode_ms_stdev": total_decode_ms_stdev,
            "total_decode_ms_min":   total_decode_ms_min,
            "total_decode_ms_max":   total_decode_ms_max,
            "total_decode_ms_cv_pct": total_decode_ms_cv_pct,
            # ---- Cache and analytic counters ----
            "kv_cache_bytes_final":   final_kv_size_bytes,
            "kv_cache_seq_len_final": args.s_init + args.max_new_tokens,
            "flops_per_step":         flops_per_step,
            "avg_cache_len":          avg_cache_len,
            # ---- Phase decomposition (teammate-CSV format) ----
            # phase_staging = the prompt-prefill / KV-cache warmup that
            # has to happen before the first decode token.
            # phase_compute = the timed decode window itself.
            # phase_output  = D2H of the final-token output tensor.
            "phase_staging_ms": phase_staging_ms,
            "phase_compute_ms": total_decode_ms,
            "phase_output_ms":  phase_output_ms,
            # ---- Achieved compute and utilization ----
            "achieved_gflops":  achieved_gflops,
            "peak_gflops":      (pk / 1e9) if pk else None,
            "utilization_pct":  util_pct,
            # ---- Energy + average power for the timed decode window ----
            # NVML on GPU, RAPL on CPU; None if neither is available.
            "energy_total_j":   energy_total_j,
            "avg_power_w":      avg_power_w,
            "tta_sec":          "N/A",
        }
        out.write(json.dumps(sample) + "\n")

    print(f"[decode]   over {args.repeats} trials × {timed_tokens} timed tokens "
          f"(warmup={args.warmup_tokens}):")
    print(f"[decode]     mean total = {total_decode_ms:.1f} ms   "
          f"stdev = {total_decode_ms_stdev:.1f} ms   "
          f"CV = {total_decode_ms_cv_pct:.1f}%   "
          f"[min {total_decode_ms_min:.1f}, max {total_decode_ms_max:.1f}]")
    print(f"[decode]     avg per-token = {avg_per_token_ms:.3f} ms   "
          f"throughput = {total_tokens_generated/total_decode_s:,.0f} tok/s (B={B})")
    print(f"[decode]   final KV cache: {final_kv_size_bytes/1e6:.2f} MB at "
          f"S = {args.s_init + args.max_new_tokens}")
    print(f"[decode]   wrote {out_path}")
    if total_decode_ms_cv_pct > 15.0:
        print(f"[decode]   WARNING: CV={total_decode_ms_cv_pct:.1f}% > 15% — "
              f"measurement is noisy. See the README hints on locking GPU "
              f"clocks (`nvidia-smi -lgc <freq>`) and disabling persistence "
              f"mode interactions.")


if __name__ == "__main__":
    main()