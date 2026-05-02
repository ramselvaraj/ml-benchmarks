"""Convert results/*.jsonl to per-model CSV files in the team's standard format.

Reads every prefill JSONL (`<model>_<dev>_<prec>.jsonl`) and decode JSONL
(`<model>_<dev>_<prec>_decode.jsonl`) under results/ and emits one
`perf_results_<model>.csv` per model into the output directory. Each
file holds both prefill and decode rows for that model — one row per
(workload, phase, batch, seq_len) cell.

CSV columns (per perf_results_standards.txt, with `total_samples` slotted
between batch_size and throughput per the team's updated spec):

    workload, dtype, batch_size, total_samples,
    throughput, latency_p50, latency_p99,
    energy_total, avg_power,
    achieved_gflops, utilization_pct, arith_intensity,
    phase_staging, phase_compute, phase_output,
    tta_sec

Workload tag combines model + variant + phase + (seq_len for prefill,
s_init+tokens for decode), so each row has a unique workload key even
when concatenated across files.

**Convention used by this exporter for attention workloads**: 1 sample =
1 token (the natural unit for LLMs). With this convention the team's
relationship `throughput = total_samples / phase_compute_seconds` holds
exactly. Concretely:

  - Prefill: total_samples = batch × seq_len × iters
             phase_compute   = median_ms × iters     (sum across iters)
             throughput      = (B × S) / median_sec  ← matches tokens_per_s
  - Decode:  total_samples = batch × timed_tokens × repeats
             phase_compute   = total_decode_ms × repeats
             throughput      = (B × timed_tokens) / total_decode_sec
                                                    ← matches tokens_per_s

Energy / power are emitted as empty cells when NVML/RAPL was unavailable
during the run (those fields are recorded as null in the JSONL).

Usage:
    python scripts/export_perf_csv.py
    python scripts/export_perf_csv.py --results-dir results --out-dir .
"""
from __future__ import annotations

import argparse
import csv
import json
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


# Teammate spec — column names and order MUST match.
COLUMNS = [
    "workload",        # string ID
    "dtype",           # precision tag
    "batch_size",
    "total_samples",   # tokens processed (prefill) or generated (decode) over the timed window
    "throughput",      # samples/s == total_samples / phase_compute_sec
    "latency_p50",     # ms
    "latency_p99",     # ms
    "energy_total",    # J
    "avg_power",       # W
    "achieved_gflops",
    "utilization_pct", # decimal 0..1
    "arith_intensity", # FLOPs/byte
    "phase_staging",   # ms
    "phase_compute",   # ms — TOTAL compute time across all iters/trials
    "phase_output",    # ms
    "tta_sec",         # "N/A" for inference
]


def _workload_tag(meta: dict, sample: dict) -> str:
    """Stable ID per measurement cell. Mirrors the team's `mnist_cnn` style:
    `<model>_<variant>_<phase>_b<B>_s<S>` (or `s<s_init>+<tokens>` for decode)."""
    model = sample.get("model") or meta.get("model")
    variant = (sample.get("variant") or meta.get("variant") or "").lower()
    phase = sample.get("phase") or meta.get("phase") or "prefill"
    batch = sample["batch"]
    if phase == "decode":
        s_init = sample.get("s_init", "?")
        toks = sample.get("tokens_decoded", "?")
        shape_tag = f"sinit{s_init}+t{toks}"
    else:
        shape_tag = f"s{sample.get('seq_len', '?')}"
    return f"{model}_{variant}_{phase}_b{batch}_{shape_tag}"


def _totals(meta: dict, sample: dict) -> tuple[int, float]:
    """Compute (total_samples, total_phase_compute_ms) consistent with the
    team's CSV invariant `throughput == total_samples / phase_compute_sec`.

    For attention workloads, 1 sample = 1 token. See module docstring."""
    phase = sample.get("phase") or meta.get("phase") or "prefill"
    B = int(sample["batch"])
    if phase == "decode":
        # timed_tokens is the post-warmup window size; tokens_decoded
        # (the older field) is the total including warmup. timed_tokens
        # is the right denominator for end-to-end throughput. Fall back
        # to tokens_decoded for older JSONLs that don't have timed_tokens.
        timed_tokens = int(sample.get("timed_tokens")
                           or sample.get("tokens_decoded", 0))
        repeats = int(sample.get("repeats", 1))
        total_samples = B * timed_tokens * repeats
        # total_decode_ms is the mean per-trial time across `repeats`
        # trials (see decode_bench.py multi-trial aggregation). Total
        # phase-compute time across all trials is mean × repeats.
        per_trial_ms = float(sample.get("total_decode_ms", 0) or 0)
        phase_compute_ms = per_trial_ms * repeats
    else:  # prefill
        S = int(sample.get("seq_len", 1))
        # `n` carries the iters count emitted by run_bench.py's stats.
        iters = int(sample.get("n", 1))
        total_samples = B * S * iters
        # phase_compute_ms in the JSONL is the per-iter median; totalize
        # by multiplying by iters.
        median_ms = float(sample.get("median_ms")
                          or sample.get("phase_compute_ms", 0) or 0)
        phase_compute_ms = median_ms * iters
    return total_samples, phase_compute_ms


def _row_for(meta: dict, sample: dict) -> dict:
    util = sample.get("utilization_pct")
    total_samples, phase_compute_ms = _totals(meta, sample)

    # Throughput in samples (= tokens) per second. By construction this
    # matches our existing tokens_per_s field for both prefill and decode;
    # we recompute from total_samples / phase_compute_sec so the CSV's
    # internal arithmetic invariant holds even if the underlying fields
    # were rounded slightly during JSONL emission.
    throughput = (total_samples * 1000.0 / phase_compute_ms) if phase_compute_ms > 0 else None

    return {
        "workload":        _workload_tag(meta, sample),
        "dtype":           sample.get("precision") or meta.get("precision"),
        "batch_size":      sample["batch"],
        "total_samples":   total_samples,
        "throughput":      throughput,
        # Prefill rows still have p50/p99 (median/percentile across `iters`
        # repeats of the same call). Decode rows no longer have them — decode
        # is timed end-to-end as one window, with only an average. Fall back
        # to avg_per_token_ms so the column isn't blank for decode rows.
        "latency_p50":     sample.get("p50_ms")
                           or sample.get("median_ms")
                           or sample.get("avg_per_token_ms"),
        "latency_p99":     sample.get("p99_ms"),
        "energy_total":    sample.get("energy_total_j"),
        "avg_power":       sample.get("avg_power_w"),
        "achieved_gflops": sample.get("achieved_gflops"),
        "utilization_pct": util,
        "arith_intensity": sample.get("arithmetic_intensity"),
        "phase_staging":   sample.get("phase_staging_ms"),
        "phase_compute":   phase_compute_ms,
        "phase_output":    sample.get("phase_output_ms"),
        "tta_sec":         sample.get("tta_sec", "N/A"),
    }


def _load_jsonl(path: Path) -> tuple[dict | None, list[dict]]:
    meta, samples = None, []
    with open(path) as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            row = json.loads(line)
            kind = row.get("kind", "")
            if kind.startswith("meta"):
                meta = row
            elif kind.startswith("sample"):
                samples.append(row)
            # ignore any leftover "per_token" rows from older JSONLs
    return meta, samples


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--results-dir", default=str(ROOT / "results"))
    ap.add_argument("--out-dir", default=str(ROOT),
                    help="Directory to write per-model CSV files into. "
                         "Output filenames: perf_results_<model>.csv. "
                         "Defaults to the repo root.")
    args = ap.parse_args()

    res = Path(args.results_dir)
    if not res.exists():
        raise SystemExit(f"results dir not found: {res}")

    files = sorted(res.glob("*.jsonl"))
    if not files:
        raise SystemExit(f"no JSONL files under {res}")

    # Group rows by source model so each model gets its own CSV.
    by_model: dict[str, list[dict]] = defaultdict(list)
    for fp in files:
        meta, samples = _load_jsonl(fp)
        for s in samples:
            model = s.get("model") or (meta or {}).get("model") or "unknown"
            by_model[model].append(_row_for(meta or {}, s))

    out_dir = Path(args.out_dir)
    out_dir.mkdir(parents=True, exist_ok=True)

    total_rows = 0
    for model, model_rows in sorted(by_model.items()):
        out_path = out_dir / f"perf_results_{model}.csv"
        with open(out_path, "w", newline="") as f:
            w = csv.DictWriter(f, fieldnames=COLUMNS)
            w.writeheader()
            for r in model_rows:
                # CSV quirks: None → empty cell (so missing energy doesn't read as "0").
                w.writerow({k: ("" if v is None else v) for k, v in r.items()})
        print(f"[export] {model:24s}  {len(model_rows):4d} rows  -> {out_path.name}")
        total_rows += len(model_rows)

    print(f"[export] read {len(files)} JSONL files, "
          f"wrote {total_rows} rows across {len(by_model)} per-model CSV files "
          f"in {out_dir}/")


if __name__ == "__main__":
    main()