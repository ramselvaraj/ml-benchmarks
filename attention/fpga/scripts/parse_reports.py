"""Scrape Vitis HLS csynth.rpt + cosim.rpt and emit a JSONL row per shape
in the same schema as the CPU/GPU runs. Drop into parent repo's results/
and the plotter automatically prefers this over synthesized placeholders.

Usage:
    python scripts/parse_reports.py \\
        --model llama2_7b_mha \\
        --variant MHA \\
        --precision int8 \\
        --csynth reports/csynth.rpt \\
        --cosim  reports/cosim.rpt \\
        --seq-len 1024 --batch 1 \\
        --out ../results/llama2_7b_mha_fpga_u280_int8.jsonl

If --cosim is omitted, we fall back to the csynth estimated latency, which
is less defensible but enough to populate the plot.
"""
from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path


# -----------------------------------------------------------------------------
# Regexes — tuned to Vitis HLS 2023.2 report format. Adjust if on a different
# vintage of the tool.
# -----------------------------------------------------------------------------

# Example line: "|Worst Case Latency| 12345678 | ... |"
_RE_LATENCY_CYCLES = re.compile(
    r"Latency[^|]*\|\s*(\d+)\s*\|\s*(\d+)\s*\|", re.IGNORECASE)

_RE_CLOCK = re.compile(
    r"Target\s*\|.*?\|\s*(\d+\.?\d*)\s*\|.*?Estimated", re.DOTALL)

_RE_DSP  = re.compile(r"DSP[^|]*\|[^|]*\|\s*(\d+)\s*\|\s*\d+\s*\|\s*(\d+)")
_RE_BRAM = re.compile(r"BRAM[^|]*\|[^|]*\|\s*(\d+)\s*\|\s*\d+\s*\|\s*(\d+)")
_RE_URAM = re.compile(r"URAM[^|]*\|[^|]*\|\s*(\d+)\s*\|\s*\d+\s*\|\s*(\d+)")
_RE_LUT  = re.compile(r"LUT[^|]*\|[^|]*\|\s*(\d+)\s*\|\s*\d+\s*\|\s*(\d+)")
_RE_FF   = re.compile(r"FF[^|]*\|[^|]*\|\s*(\d+)\s*\|\s*\d+\s*\|\s*(\d+)")


def grep_first(pattern: re.Pattern, text: str, group: int = 1) -> str | None:
    m = pattern.search(text)
    return m.group(group) if m else None


def parse_csynth(path: Path) -> dict:
    text = path.read_text()
    out = {}
    # Target clock period (ns). Tool reports "Target Clock | 3.33 ns | Estimated ..."
    m = re.search(r"Target\s*\|\s*ap_clk\s*\|\s*(\d+\.?\d*)\s*ns", text)
    if m: out["target_period_ns"] = float(m.group(1))
    m = re.search(r"Estimated\s*\|\s*ap_clk\s*\|\s*(\d+\.?\d*)\s*ns", text)
    if m: out["estimated_period_ns"] = float(m.group(1))
    # Latency (cycles) — "Worst Case Latency | N cycles | ..."
    m = re.search(r"Worst-case latency[\s\S]{0,200}?(\d+)\s+cycles", text, re.IGNORECASE)
    if m: out["worst_case_cycles"] = int(m.group(1))
    # Utilization: pull the first DSP / BRAM / URAM / LUT / FF counts in the
    # Utilization Estimates table.
    m = _RE_DSP.search(text);  out["dsp_used"]  = int(m.group(2)) if m else None
    m = _RE_BRAM.search(text); out["bram_used"] = int(m.group(2)) if m else None
    m = _RE_URAM.search(text); out["uram_used"] = int(m.group(2)) if m else None
    m = _RE_LUT.search(text);  out["lut_used"]  = int(m.group(2)) if m else None
    m = _RE_FF.search(text);   out["ff_used"]   = int(m.group(2)) if m else None
    return out


def parse_cosim(path: Path) -> dict | None:
    if not path.exists():
        return None
    text = path.read_text()
    m = re.search(r"Total.*?(\d+)\s+cycles?", text, re.IGNORECASE)
    if m: return {"cosim_cycles": int(m.group(1))}
    return None


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--model",     required=True)
    p.add_argument("--variant",   required=True, choices=["MHA", "MQA", "GQA"])
    p.add_argument("--precision", required=True, choices=["int8", "int4"])
    p.add_argument("--csynth",    required=True)
    p.add_argument("--cosim",     default=None, help="(optional)")
    p.add_argument("--seq-len",   type=int, default=1024)
    p.add_argument("--batch",     type=int, default=1)
    p.add_argument("--hidden",    type=int, default=4096)
    p.add_argument("--out",       required=True)
    args = p.parse_args()

    syn = parse_csynth(Path(args.csynth))
    co  = parse_cosim(Path(args.cosim)) if args.cosim else None

    # Cycles to use for latency calculation.
    cycles = None
    source = None
    if co and "cosim_cycles" in co:
        cycles = co["cosim_cycles"]; source = "cosim"
    elif "worst_case_cycles" in syn:
        cycles = syn["worst_case_cycles"]; source = "csynth_worst_case"
    else:
        print("ERROR: could not extract cycles from either report", file=sys.stderr)
        sys.exit(1)

    period_ns = syn.get("estimated_period_ns") or syn.get("target_period_ns") or 3.33
    fmax_mhz  = 1000.0 / period_ns
    latency_ms = cycles * period_ns / 1e6   # ns → ms

    meta = {
        "kind":            "meta",
        "model":           args.model,
        "variant":         args.variant,
        "device":          "fpga_u280",
        "precision":       args.precision,
        "seed":            1234,
        "sdpa_backend":    "hls_fused",
        "torch_version":   "n/a",
        "platform":        "xcu280-fsvh2892-2L-e",
        "fmax_mhz":        round(fmax_mhz, 1),
        "cycles_source":   source,
        "dsp_used":        syn.get("dsp_used"),
        "bram_used":       syn.get("bram_used"),
        "uram_used":       syn.get("uram_used"),
        "lut_used":        syn.get("lut_used"),
        "ff_used":         syn.get("ff_used"),
        "target_period_ns":    syn.get("target_period_ns"),
        "estimated_period_ns": syn.get("estimated_period_ns"),
    }

    sample = {
        "kind":          "sample",
        "model":         args.model,
        "variant":       args.variant,
        "device":        "fpga_u280",
        "precision":     args.precision,
        "batch":         args.batch,
        "seq_len":       args.seq_len,
        "median_ms":     round(latency_ms, 4),
        "p50_ms":        round(latency_ms, 4),
        "p95_ms":        round(latency_ms, 4),
        "p99_ms":        round(latency_ms, 4),
        "mean_ms":       round(latency_ms, 4),
        "stdev_ms":      0.0,
        "n":             1,
        "tokens_per_s":  (args.batch * args.seq_len) / (latency_ms / 1000.0),
        "weights_bytes": 0,
        "peak_bytes":    0,
        "kv_cache_bytes": 0,
        "flops":         0,   # filled in separately if you want — not needed for
        "bytes_moved":   0,   # plot_results.py which can re-derive from shapes
        "arithmetic_intensity": 0.0,
        "cycles":        cycles,
        "_fpga_hls_synth": True,
    }

    out_path = Path(args.out)
    out_path.parent.mkdir(parents=True, exist_ok=True)
    with open(out_path, "w") as f:
        f.write(json.dumps(meta) + "\n")
        f.write(json.dumps(sample) + "\n")

    print(f"[parse] {source}  cycles={cycles}  fmax={fmax_mhz:.1f} MHz  "
          f"latency={latency_ms:.3f} ms")
    print(f"[parse] wrote {out_path}")


if __name__ == "__main__":
    main()
