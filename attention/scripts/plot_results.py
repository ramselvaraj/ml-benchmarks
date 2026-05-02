"""Load every JSONL in results/ and emit the paper's headline figures.

CLI:
    python scripts/plot_results.py
    python scripts/plot_results.py --with-fpga-placeholders   # synthesize estimated FPGA bars
    python scripts/plot_results.py --share-y                  # legacy shared y-axis

By default FPGA placeholder rows are NOT synthesized. They visually dominate
the precision-bar chart and can mislead a reader into thinking we have
hardware data we don't. Pass --with-fpga-placeholders to render them; even
then they're hatched, faded, marked "(est.)", and skipped entirely for MLA
(which is documented as out of scope for the FPGA cell). Once real
`_fpga_u280_*.jsonl` files exist they'll be picked up automatically.

Outputs (all under plots/):
    latency_vs_seq.png             latency vs seq_len at batch=1, per model
    throughput_vs_batch.png        tokens/s vs batch at seq_len=1024, per model
    roofline.png                   achieved throughput vs arithmetic intensity
    roofline_per_cell/             one roofline per (device, precision)
    precision_bars.png             cross-precision comparison at (B, S)
    utilization_per_cell.png       achieved / peak per (model, dev, precision)
    phase_decomposition.png        staging / compute / output stacked bars
    decode_*.png                   decode-phase plots (require *_decode.jsonl)
    mla_decode_kv_traffic.png      bytes-per-decode-step across variants
    summary.md                     text summary of cells populated
"""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Any

import matplotlib.pyplot as plt
import numpy as np

ROOT = Path(__file__).resolve().parents[1]
RESULTS = ROOT / "results"
PLOTS = ROOT / "plots"
PLOTS.mkdir(exist_ok=True)
sys.path.insert(0, str(ROOT))


# -----------------------------------------------------------------------------
# Platform peaks — single source of truth in src/bench/peaks.py.
# -----------------------------------------------------------------------------
from src.bench.peaks import PLATFORM_PEAK_TOPS, PLATFORM_BW_GBPS  # noqa: E402

# Per-device base colormap, picked so shades within a device still read as
# "that device" at a glance but each precision is distinguishable.
_DEVICE_CMAPS = {
    "cpu":       plt.cm.Blues,
    "cuda":      plt.cm.Reds,
    "fpga_u280": plt.cm.Greens,
}

# Per-precision "brightness" in the device's colormap. Higher = darker shade
# (matplotlib sequential cmaps go light→dark as the index rises). BF16 is
# the canonical reference, so it's the darkest; the less-faithful integer
# variants (int4_torchao, nf4) sit in the lighter/pastel range.
_PRECISION_BRIGHTNESS = {
    "bf16":          0.90,
    "fp32":          0.80,
    "fp16":          0.85,
    "int8":          0.70,
    "int4":          0.55,
    "int8_wo":       0.45,
    "int8_compiled": 0.62,
    "int4_torchao":  0.38,
    "nf4":           0.30,
    "int8_bnb":      0.25,
}

# One-stop "device color that also represents the base shade of the device".
# Used by the roofline ridge lines and any place we want a neutral per-device
# hue independent of precision.
DEVICE_COLORS = {
    "cpu":       plt.cm.Blues(0.75),
    "cuda":      plt.cm.Reds(0.75),
    "fpga_u280": plt.cm.Greens(0.75),
}


def device_precision_color(device: str, precision: str):
    """Return a per-(device, precision) color in the device's colormap."""
    cmap = _DEVICE_CMAPS.get(device, plt.cm.Greys)
    brightness = _PRECISION_BRIGHTNESS.get(precision, 0.50)
    return cmap(brightness)


PRECISION_LINESTYLES = {
    "bf16":          "-",
    "int8":          "--",
    "int4":          ":",
    "int8_wo":       (0, (5, 2)),
    "int8_compiled": (0, (3, 1, 1, 1)),
    "int4_torchao":  (0, (3, 1, 1, 1, 1, 1)),
    "nf4":           (0, (1, 1)),
    "int8_bnb":      (0, (4, 1, 1, 1)),
    "fp16":          (0, (2, 2)),
    "fp32":          (0, (6, 1)),
}

# Realistic FPGA utilization factor (empirical; tune once real numbers exist)
FPGA_UTIL = 0.45


# -----------------------------------------------------------------------------
# Data loading
# -----------------------------------------------------------------------------

def load_jsonl(path: Path) -> tuple[dict | None, list[dict]]:
    meta, samples = None, []
    with open(path) as f:
        for line in f:
            row = json.loads(line)
            if row.get("kind") == "meta":
                meta = row
            else:
                samples.append(row)
    return meta, samples


def load_all_results() -> list[dict]:
    """Return a flat list of every PREFILL sample row across every jsonl in
    results/. Decode-phase rows (kind ∈ {"sample_decode", "per_token"}) are
    filtered out so existing prefill plots don't accidentally pick them up."""
    rows = []
    for p in sorted(RESULTS.glob("*.jsonl")):
        _, samples = load_jsonl(p)
        for s in samples:
            if s.get("kind") in ("sample_decode", "per_token", "meta_decode"):
                continue
            s["_source"] = p.name
            s["_placeholder"] = False
            rows.append(s)
    return rows


def load_all_decode_results() -> list[dict]:
    """Return summary rows (kind == 'sample_decode') from every
    *_decode.jsonl file. Per-token traces no longer exist — decode is now
    measured end-to-end with one window, not per-step. The total wall
    time and average per-token latency live on the summary row."""
    summary = []
    for p in sorted(RESULTS.glob("*_decode.jsonl")):
        with open(p) as f:
            for line in f:
                row = json.loads(line)
                if row.get("kind") == "sample_decode":
                    summary.append(row)
    return summary


# -----------------------------------------------------------------------------
# FPGA placeholder synthesis
# -----------------------------------------------------------------------------

def synthesize_fpga_rows(real_rows: list[dict]) -> list[dict]:
    """For each (model, batch, seq_len) present in the real data at a given
    precision where FPGA is expected, synthesize an FPGA row via roofline.

    We synthesize for every (model, B, S) that has a GPU BF16 row, at
    precisions int8 and int4. The FPGA latency is max(compute_time,
    memory_time), with compute utilization FPGA_UTIL.

    **MLA models are excluded from FPGA synthesis** per the methodology
    decision — the FPGA cell measures MHA/MQA/GQA only, and inventing an
    "MLA on FPGA" placeholder would misrepresent the project's scope.
    """
    synth = []
    # Unique (model, batch, seq_len, variant) from the GPU BF16 track,
    # excluding MLA (FPGA out of scope for that variant).
    templates = {}
    for r in real_rows:
        if r["device"] == "cuda" and r["precision"] == "bf16":
            if r.get("variant") == "MLA":
                continue
            key = (r["model"], r["batch"], r["seq_len"])
            templates[key] = r

    for (model, B, S), template in templates.items():
        flops = template["flops"]
        bytes_moved = template["bytes_moved"]
        bw = PLATFORM_BW_GBPS["fpga_u280"] * 1e9

        for precision in ("int8", "int4"):
            peak = PLATFORM_PEAK_TOPS[("fpga_u280", precision)]
            compute_s = flops / (peak * FPGA_UTIL)
            memory_s  = bytes_moved / bw
            latency_s = max(compute_s, memory_s)
            latency_ms = latency_s * 1000
            synth.append({
                "kind":          "sample",
                "model":         model,
                "variant":       template["variant"],
                "device":        "fpga_u280",
                "precision":     precision,
                "batch":         B,
                "seq_len":       S,
                "median_ms":     latency_ms,
                "p50_ms":        latency_ms,
                "p95_ms":        latency_ms * 1.05,
                "p99_ms":        latency_ms * 1.10,
                "mean_ms":       latency_ms,
                "stdev_ms":      0.0,
                "n":             1,
                "tokens_per_s":  (B * S) / latency_s,
                "weights_bytes": template["weights_bytes"],
                "peak_bytes":    template.get("peak_bytes", 0),
                "kv_cache_bytes": template["kv_cache_bytes"],
                "flops":         flops,
                "bytes_moved":   bytes_moved,
                "arithmetic_intensity": template["arithmetic_intensity"],
                "_source":       "synthesized",
                "_placeholder":  True,
            })
    return synth


# -----------------------------------------------------------------------------
# Figures
# -----------------------------------------------------------------------------

def _subset(rows, **kv):
    out = rows
    for k, v in kv.items():
        out = [r for r in out if r.get(k) == v]
    return out


def _label(r):
    dev = r["device"]
    prec = r["precision"]
    placeholder = " (est.)" if r["_placeholder"] else ""
    dev_pretty = {"cpu": "CPU EPYC 9354", "cuda": "GPU L40S", "fpga_u280": "FPGA U280"}[dev]
    return f"{dev_pretty} · {prec}{placeholder}"


def fig_latency_vs_seq(rows, out_path, share_y: bool = False):
    """Latency vs seq_len at batch=1, one panel per model. Laid out as a
    3-column × 2-row grid (5 models fit, 6th cell is hidden). Per-panel
    y-axis by default — when one model is much slower than others (e.g.
    DeepSeek MLA vs StarCoder MQA), shared-y squashes the faster panels
    into a single line. Pass share_y=True to revert to the legacy
    shared scale."""
    models = sorted({r["model"] for r in rows})
    n_cols = 3
    n_rows = 2
    fig, axes_grid = plt.subplots(n_rows, n_cols,
                                  figsize=(5.5 * n_cols, 4.5 * n_rows),
                                  sharey=share_y)
    axes_flat = axes_grid.flatten()

    last_used_ax = axes_flat[0]
    for idx, model in enumerate(models):
        ax = axes_flat[idx]
        last_used_ax = ax
        ms = _subset(rows, model=model, batch=1)
        # Group by (device, precision)
        groups = {}
        for r in ms:
            k = (r["device"], r["precision"], r["_placeholder"])
            groups.setdefault(k, []).append(r)

        for (dev, prec, is_placeholder), rs in sorted(groups.items()):
            rs = sorted(rs, key=lambda r: r["seq_len"])
            xs = [r["seq_len"] for r in rs]
            ys = [r["median_ms"] for r in rs]
            ax.plot(xs, ys,
                    color=device_precision_color(dev, prec),
                    linestyle=PRECISION_LINESTYLES.get(prec, "-"),
                    alpha=0.55 if is_placeholder else 1.0,
                    marker="o" if not is_placeholder else "x",
                    markersize=4,
                    linewidth=1.8,
                    label=_label(rs[0]))

        ax.set_xscale("log", base=2)
        ax.set_yscale("log")
        ax.set_xlabel("seq_len")
        ax.set_title(f"{model}  (batch=1)")
        ax.grid(True, alpha=0.3, which="both")
        # Y-label only on the leftmost column.
        if idx % n_cols == 0:
            ax.set_ylabel("median latency (ms)")

    # Hide any unused panels in the grid.
    for k in range(len(models), len(axes_flat)):
        axes_flat[k].set_visible(False)

    # One shared legend to the right of the grid.
    h, l = last_used_ax.get_legend_handles_labels()
    fig.legend(h, l, loc="center right", bbox_to_anchor=(1.12, 0.5), fontsize=8)
    fig.suptitle("Attention-layer latency vs seq_len @ batch=1", y=1.00)
    fig.tight_layout()
    fig.savefig(out_path, bbox_inches="tight", dpi=140)
    plt.close(fig)


def fig_throughput_vs_batch(rows, out_path, share_y: bool = False):
    """Throughput vs batch at seq_len=1024, one panel per model. Laid out
    as a 3-column × 2-row grid (5 models fit, 6th cell is hidden).
    Per-panel y by default for the same reason as fig_latency_vs_seq.

    **Important: each panel's y-axis is pinned to start from 0.** Without
    this, matplotlib auto-scales each panel to its data range, which makes
    20%-amplitude variation look like 100% swings (DeepSeek's 0.32-0.40
    M tok/s renders with the full panel height worth of wiggle if y
    starts at 0.32). Pinning to zero preserves the per-panel max but keeps
    the relative scale honest — flat-ish lines look flat. Pass
    share_y=True for the legacy shared-y view if you prefer it."""
    models = sorted({r["model"] for r in rows})
    n_cols = 3
    n_rows = 2
    fig, axes_grid = plt.subplots(n_rows, n_cols,
                                  figsize=(5.5 * n_cols, 4.5 * n_rows),
                                  sharey=share_y)
    axes_flat = axes_grid.flatten()

    last_used_ax = axes_flat[0]
    for idx, model in enumerate(models):
        ax = axes_flat[idx]
        last_used_ax = ax
        ms = _subset(rows, model=model, seq_len=1024)
        groups = {}
        for r in ms:
            k = (r["device"], r["precision"], r["_placeholder"])
            groups.setdefault(k, []).append(r)

        for (dev, prec, is_placeholder), rs in sorted(groups.items()):
            rs = sorted(rs, key=lambda r: r["batch"])
            xs = [r["batch"] for r in rs]
            ys = [r["tokens_per_s"] / 1e6 for r in rs]
            ax.plot(xs, ys,
                    color=device_precision_color(dev, prec),
                    linestyle=PRECISION_LINESTYLES.get(prec, "-"),
                    alpha=0.55 if is_placeholder else 1.0,
                    marker="o" if not is_placeholder else "x",
                    markersize=4,
                    linewidth=1.8,
                    label=_label(rs[0]))

        ax.set_xscale("log", base=2)
        ax.set_xlabel("batch")
        ax.set_title(f"{model}  (seq_len=1024)")
        ax.grid(True, alpha=0.3, which="both")
        # Pin per-panel y-axis to start from 0 (only when not sharing y).
        # Auto-scaled tight ranges turn small noise into visual chaos.
        if not share_y:
            ax.set_ylim(bottom=0)
        # Y-label only on the leftmost column.
        if idx % n_cols == 0:
            ax.set_ylabel("throughput (M tokens/s)")

    # Hide any unused panels in the grid.
    for k in range(len(models), len(axes_flat)):
        axes_flat[k].set_visible(False)

    h, l = last_used_ax.get_legend_handles_labels()
    fig.legend(h, l, loc="center right", bbox_to_anchor=(1.12, 0.5), fontsize=8)
    fig.suptitle("Attention-layer throughput vs batch @ seq_len=1024", y=1.00)
    fig.tight_layout()
    fig.savefig(out_path, bbox_inches="tight", dpi=140)
    plt.close(fig)


# Per-model markers to distinguish models within a single cell. Includes
# both tiers of the lineup (3× 7B-class for variant comparison + 2× large
# for the SOTA face-off). Models without an entry default to "o" via .get().
_MODEL_MARKERS = {
    # Tier 1 — 7B variant comparison
    "llama2_7b_mha":     ("o", "Llama-2-7B (MHA)"),
    "mistral_7b_gqa":    ("s", "Mistral-7B (GQA)"),
    "starcoder_7b_mqa":  ("^", "StarCoder-7B (MQA)"),
    # Tier 2 — production-scale SOTA face-off
    "llama31_70b_gqa":   ("D", "Llama-3.1-70B (GQA)"),
    "deepseek_v2_mla":   ("*", "DeepSeek-V2 (MLA)"),
}


# Seven distinct colors, one per seq_len. Sampled from `turbo` (modern rainbow,
# high perceptual contrast, and none of the saturated hues collide with our
# device-color ridge lines: red/blue/green).
def _seq_color_map(seq_lens: list[int]) -> dict[int, tuple]:
    import matplotlib.cm as cm
    xs = sorted(set(seq_lens))
    if len(xs) == 1:
        return {xs[0]: cm.turbo(0.5)}
    return {s: cm.turbo(0.08 + 0.88 * i / (len(xs) - 1))
            for i, s in enumerate(xs)}


def _seq_len_label(s: int) -> str:
    return f"{s // 1024}K" if s >= 1024 else str(s)


def _best_batch_per_cell(rows: list[dict]) -> dict[tuple, int]:
    """For each (model, device, precision) triple, pick the batch size that
    achieved the highest *peak* throughput anywhere in its seq_len sweep.

    Tie-break: prefer the smaller batch (more conservative, cleaner compute-
    bound-regime visualization on the roofline).

    Returns a dict: (model, device, precision) -> best_batch
    """
    from collections import defaultdict
    by_cell: dict[tuple, dict[int, list[dict]]] = defaultdict(lambda: defaultdict(list))
    for r in rows:
        cell = (r["model"], r["device"], r["precision"])
        by_cell[cell][r["batch"]].append(r)

    best: dict[tuple, int] = {}
    for cell, by_batch in by_cell.items():
        # Score each batch by its *best* achieved throughput across seq_lens.
        scores = {}
        for batch, rs in by_batch.items():
            peak = max((r["flops"] / (r["median_ms"] / 1000.0)) for r in rs)
            scores[batch] = peak
        # argmax, tie-broken by smaller batch
        best_batch = min(
            (b for b in scores if scores[b] == max(scores.values())),
            default=min(by_batch.keys()),
        )
        best[cell] = best_batch
    return best


def _filter_best_batch(rows: list[dict]) -> list[dict]:
    """Reduce rows to a 'best-batch-per-cell' subset — one batch per
    (model, device, precision), sweeping over all its seq_lens."""
    best = _best_batch_per_cell(rows)
    return [r for r in rows
            if best.get((r["model"], r["device"], r["precision"])) == r["batch"]]


# Batch used for roofline plots. Single value so every (model, device, precision)
# cell is rendered at the same batch, making cross-platform reading direct.
# Tweak here and every roofline figure follows.
ROOFLINE_BATCH = 16

# Reference shape for the cross-precision bar chart. Tweak these and the
# precision_bars figure retargets automatically.
PRECISION_BARS_BATCH = 16
PRECISION_BARS_SEQ   = 1024


def _filter_fixed_batch(rows: list[dict], batch: int = ROOFLINE_BATCH) -> list[dict]:
    """Keep only rows measured at `batch`. If a cell has no rows at that
    batch (e.g., some sweep was aborted), fall back to whichever batch is
    present — closest rule: largest available batch <= target."""
    result = []
    # Group by cell so we can handle fallback per-cell
    from collections import defaultdict
    by_cell: dict[tuple, list[dict]] = defaultdict(list)
    for r in rows:
        by_cell[(r["model"], r["device"], r["precision"])].append(r)

    for cell, cell_rows in by_cell.items():
        batches_present = sorted({r["batch"] for r in cell_rows})
        if batch in batches_present:
            pick = batch
        else:
            # Fallback: largest batch <= target, else smallest available.
            smaller_or_eq = [b for b in batches_present if b <= batch]
            pick = max(smaller_or_eq) if smaller_or_eq else min(batches_present)
        result.extend(r for r in cell_rows if r["batch"] == pick)
    return result


def fig_roofline_per_cell(rows, out_dir: Path) -> None:
    """Emit one roofline per (device, precision) combination.

    Each figure shows a single ridge line + only the scatter points that
    belong to that cell, differentiated by model shape. The cleanest
    teaching visual — one story per plot, no visual cross-talk.

    We filter to ONE batch (ROOFLINE_BATCH, default 16) across every cell.
    This keeps the scatter legible (7 dots per model instead of 28), makes
    CPU/GPU/FPGA rooflines directly comparable at a single fixed work unit,
    and isolates the "kernel efficiency" axis from the "batch scaling" axis.
    Batch-scaling behavior is captured separately by fig_throughput_vs_batch.
    """
    out_dir.mkdir(parents=True, exist_ok=True)
    rows = _filter_fixed_batch(rows, ROOFLINE_BATCH)

    # Every cell present in the data OR synthesized, for which we have peak data.
    cells = set()
    for r in rows:
        key = (r["device"], r["precision"])
        if key in PLATFORM_PEAK_TOPS:
            cells.add(key)

    ai_range = np.logspace(0, 4, 300)

    for dev, prec in sorted(cells):
        peak_tops = PLATFORM_PEAK_TOPS[(dev, prec)]
        bw        = PLATFORM_BW_GBPS[dev] * 1e9
        ai_ridge  = peak_tops / bw                        # FLOPs/byte at the corner
        peak_tflops = peak_tops / 1e12

        fig, ax = plt.subplots(figsize=(8, 6))

        # --- Roofline ridge ---
        mem_bound     = ai_range * bw
        compute_bound = np.full_like(mem_bound, peak_tops)
        achievable    = np.minimum(mem_bound, compute_bound)
        ridge_color   = device_precision_color(dev, prec)
        ax.plot(ai_range, achievable / 1e12,
                color=ridge_color, linewidth=2.5)

        # Dashed drop-lines at the ridge corner for visual reference
        ax.axvline(ai_ridge, color="gray", linestyle="--", alpha=0.45, linewidth=0.9)
        ax.axhline(peak_tflops, color="gray", linestyle="--", alpha=0.45, linewidth=0.9)
        ax.plot([ai_ridge], [peak_tflops],
                marker="D", color=ridge_color, markeredgecolor="black",
                markersize=9, markeredgewidth=0.8, zorder=4)

        # Annotate the ridge point directly on the chart so the reader doesn't
        # have to dig through the legend for it.
        ax.annotate(f"ridge · AI={ai_ridge:.0f}",
                    xy=(ai_ridge, peak_tflops),
                    xytext=(10, -12), textcoords="offset points",
                    fontsize=8, color=ridge_color, fontweight="bold")

        # --- Measurements for THIS cell only ---
        cell_rows = [r for r in rows
                     if r["device"] == dev and r["precision"] == prec]
        if not cell_rows:
            plt.close(fig)
            continue

        # Build the seq_len→color map from whatever seq_lens are present.
        seq_color = _seq_color_map([r["seq_len"] for r in cell_rows])
        sorted_seqs = sorted(seq_color.keys())

        # Collect handles for two separate legends (model shapes, seq_len colors).
        from matplotlib.lines import Line2D
        from matplotlib.patches import Patch
        model_handles = []
        batch_note = ""

        for model, (marker, pretty) in _MODEL_MARKERS.items():
            mrows = sorted([r for r in cell_rows if r["model"] == model],
                           key=lambda r: r["seq_len"])
            if not mrows:
                continue
            is_placeholder = mrows[0]["_placeholder"]
            this_batch = mrows[0]["batch"]
            if not batch_note and not is_placeholder:
                batch_note = f"B={this_batch}"  # noted in title; identical across models in practice
            xs = [r["arithmetic_intensity"] for r in mrows]
            ys = [(r["flops"] / (r["median_ms"] / 1000.0)) / 1e12 for r in mrows]
            pt_colors = [seq_color[r["seq_len"]] for r in mrows]

            # Faint trajectory line connecting the seq_len sweep.
            ax.plot(xs, ys,
                    color="dimgray", alpha=0.25, linewidth=0.8,
                    linestyle="-" if not is_placeholder else ":")

            # Colored scatter: color = seq_len, shape = model, edge = placeholder or not.
            ax.scatter(xs, ys,
                       marker=marker,
                       s=48 if not is_placeholder else 36,
                       c=pt_colors,
                       edgecolors="black" if not is_placeholder else "gray",
                       linewidth=0.6,
                       alpha=0.60 if is_placeholder else 1.0,
                       zorder=5)

            # One "shape proxy" handle for the model legend (no color).
            model_handles.append(
                Line2D([0], [0], marker=marker, color="none",
                       markerfacecolor="lightgray", markeredgecolor="black",
                       markersize=8, linewidth=0,
                       label=f"{pretty}"
                             f"{' (est.)' if is_placeholder else ''}")
            )

        # Seq_len legend — color patches, one per seq_len, in order.
        seq_handles = [
            Patch(facecolor=seq_color[s], edgecolor="black", linewidth=0.4,
                  label=f"S = {_seq_len_label(s)}")
            for s in sorted_seqs
        ]

        # Place the two legends. matplotlib only draws the last `ax.legend()` by
        # default, so we use add_artist to keep both.
        leg_models = ax.legend(handles=model_handles, loc="lower right",
                               title="model", title_fontsize=8, fontsize=8,
                               framealpha=0.9)
        ax.add_artist(leg_models)
        ax.legend(handles=seq_handles, loc="upper left",
                  title="sequence length", title_fontsize=8, fontsize=8,
                  framealpha=0.9, ncol=1)

        # --- Axes, annotation, formatting ---
        ax.set_xscale("log")
        ax.set_yscale("log")
        ax.set_xlabel("Arithmetic intensity (FLOPs / byte)")
        ax.set_ylabel("Achieved throughput (TFLOPs/s or TOPS)")
        pretty_dev = {"cpu": "CPU EPYC 9354", "cuda": "GPU L40S", "fpga_u280": "FPGA U280"}.get(dev, dev)
        # "TFLOPs" for float precisions, "TOPS" for integer precisions.
        is_float = prec in ("bf16", "fp16", "fp32")
        peak_unit = "TFLOPs" if is_float else "TOPS"
        # Figure out the actual batch rendered (may have fallen back from the
        # requested ROOFLINE_BATCH if that batch wasn't present in this cell).
        cell_rs = [r for r in rows if r["device"] == dev and r["precision"] == prec]
        real_rs = [r for r in cell_rs if not r["_placeholder"]]
        rendered_batch = (real_rs[0]["batch"] if real_rs
                          else cell_rs[0]["batch"] if cell_rs
                          else ROOFLINE_BATCH)
        ax.set_title(f"Roofline: {pretty_dev}   precision = {prec}   batch = {rendered_batch}\n"
                     f"Peak = {peak_tflops:.2f} {peak_unit}   Bandwidth = {bw/1e9:.0f} GB/s   "
                     f"Ridge = {ai_ridge:.0f} FLOPs/byte")

        # Shade the two regimes lightly for teaching clarity
        ax.axvspan(ai_range[0], ai_ridge,
                   alpha=0.05, color="blue", label="_nolegend_")   # memory-bound
        ax.axvspan(ai_ridge, ai_range[-1],
                   alpha=0.05, color="red",  label="_nolegend_")   # compute-bound

        # Annotate which regime is which
        ylim_lo, ylim_hi = ax.get_ylim()
        y_anno = ylim_lo * 1.5
        ax.text(ai_range[0] * 1.3, y_anno, "memory-bound",
                fontsize=9, color="navy", alpha=0.6)
        ax.text(ai_ridge * 1.3, y_anno, "compute-bound",
                fontsize=9, color="darkred", alpha=0.6)

        ax.grid(True, alpha=0.3, which="both")
        # The two legends (model shapes + seq_len colors) were already drawn
        # explicitly above via ax.legend(handles=...) + add_artist. Do NOT
        # call a plain ax.legend() here — it would overwrite both.
        fig.tight_layout()

        fname = f"roofline_{dev}_{prec}.png"
        fig.savefig(out_dir / fname, bbox_inches="tight", dpi=140)
        plt.close(fig)


def fig_roofline(rows, out_path):
    # Same fixed-batch filter as the per-cell plots: plot every cell at the
    # single batch specified by ROOFLINE_BATCH (default 16). Batch-scaling is
    # covered separately by fig_throughput_vs_batch.
    rows = _filter_fixed_batch(rows, ROOFLINE_BATCH)
    fig, ax = plt.subplots(figsize=(9, 6))

    # Ridge lines per (device, precision)
    ai_range = np.logspace(0, 4, 200)   # 1..10000 FLOPs/byte
    for (dev, prec), peak in PLATFORM_PEAK_TOPS.items():
        bw = PLATFORM_BW_GBPS[dev] * 1e9
        mem_bound = ai_range * bw
        compute_bound = np.full_like(mem_bound, peak)
        achievable = np.minimum(mem_bound, compute_bound)
        ax.plot(ai_range, achievable / 1e12,
                color=DEVICE_COLORS[dev],
                linestyle=PRECISION_LINESTYLES.get(prec, "-"),
                linewidth=1.2, alpha=0.5,
                label=f"{dev}·{prec} peak")

    # Scatter: color by seq_len, **marker by model**. Combined gives the
    # reader two axes of disambiguation — the seq_len gradient walks from
    # short (cool) to long (warm), and the marker shape says which
    # architecture each dot belongs to. Without the marker, the all-points
    # roofline is just an opaque cloud.
    seq_color = _seq_color_map([r["seq_len"] for r in rows])
    for r in rows:
        x = r["arithmetic_intensity"]
        y = (r["flops"] / (r["median_ms"] / 1000.0)) / 1e12
        marker, _ = _MODEL_MARKERS.get(r["model"], ("o", r["model"]))
        if r["_placeholder"]:
            ax.scatter(x, y,
                       color=seq_color[r["seq_len"]],
                       marker="x", s=22, alpha=0.45, linewidth=0.7)
        else:
            ax.scatter(x, y,
                       color=seq_color[r["seq_len"]],
                       marker=marker, s=36, alpha=0.85,
                       edgecolors="black", linewidth=0.4)

    # Two legends: model shapes (top-left) and seq_len colors (left, lower).
    from matplotlib.lines import Line2D
    from matplotlib.patches import Patch
    models_present = sorted({r["model"] for r in rows})
    model_handles = []
    for m in models_present:
        marker, label = _MODEL_MARKERS.get(m, ("o", m))
        model_handles.append(
            Line2D([0], [0], marker=marker, color="none",
                   markerfacecolor="lightgray", markeredgecolor="black",
                   markersize=8, linewidth=0, label=label)
        )
    leg_models = ax.legend(handles=model_handles, loc="upper left",
                           title="model", title_fontsize=8,
                           fontsize=8, framealpha=0.9)
    ax.add_artist(leg_models)

    seq_handles = [
        Patch(facecolor=seq_color[s], edgecolor="black", linewidth=0.4,
              label=f"S = {_seq_len_label(s)}")
        for s in sorted(seq_color.keys())
    ]
    leg_seq = ax.legend(handles=seq_handles, loc="center left",
                        bbox_to_anchor=(0.0, 0.55),
                        title="sequence length", title_fontsize=8,
                        fontsize=8, framealpha=0.9)
    ax.add_artist(leg_seq)

    ax.set_xscale("log")
    ax.set_yscale("log")
    ax.set_xlabel("Arithmetic intensity (FLOPs / byte)")
    ax.set_ylabel("Achieved throughput (TFLOPs/s or TOPS)")
    ax.set_title("Roofline: all (model, device, precision) measurements")
    ax.grid(True, alpha=0.3, which="both")
    ax.legend(fontsize=8, ncol=2, loc="lower right")
    fig.tight_layout()
    fig.savefig(out_path, bbox_inches="tight", dpi=140)
    plt.close(fig)


def fig_precision_bars(rows, out_path,
                       batch: int = PRECISION_BARS_BATCH,
                       seq_len: int = PRECISION_BARS_SEQ):
    """Bar chart of latency at a single reference shape for each
    (model, device, precision). Reference shape is (batch, seq_len); defaults
    to the module-level PRECISION_BARS_BATCH / PRECISION_BARS_SEQ constants.

    Per-panel y-axis on this chart is **misleading** because tiny
    measurement variance at (e.g.) llama31_70b_gqa where bf16=29ms and
    int8_wo=27ms gets stretched to fill the panel and reads as a 10%
    "improvement" that's actually within noise. We pin a shared linear
    y-axis across panels here so the cross-model comparison is honest. For
    the cross-model story specifically, see also fig_model_comparison_bars
    which puts all models on one axis at a fixed precision.

    If the exact (batch, seq_len) cell isn't present for some row (e.g., a
    sweep was truncated), that platform/precision silently drops out of
    that model's panel.
    """
    pick = [r for r in rows if r["batch"] == batch and r["seq_len"] == seq_len]
    if not pick:
        print(f"[plot] fig_precision_bars: no rows at B={batch} S={seq_len}; "
              f"skipping figure.")
        return
    models = sorted({r["model"] for r in pick})

    # SHARED y across panels — see docstring. Linear scale makes within-panel
    # noise look like noise instead of like a "10% speedup".
    fig, axes = plt.subplots(1, len(models), figsize=(5.5 * len(models), 4.5),
                             sharey=True)
    if len(models) == 1:
        axes = [axes]

    # Stable per-(device, precision) ordering; cells absent from the data
    # are silently dropped instead of hardcoded.
    _DEV_RANK = {"cpu": 0, "cuda": 1, "fpga_u280": 2}
    _PREC_RANK = {
        "fp32": 0, "fp16": 1, "bf16": 2,
        "int8": 10, "int8_compiled": 11, "int4": 12,
        "int8_wo": 20, "int4_torchao": 21, "nf4": 22, "int8_bnb": 23,
    }

    for ax, model in zip(axes, models):
        ms = [r for r in pick if r["model"] == model]
        cells_present = sorted(
            {(r["device"], r["precision"]) for r in ms},
            key=lambda dp: (_DEV_RANK.get(dp[0], 99), _PREC_RANK.get(dp[1], 99)),
        )
        rows_ordered = []
        labels = []
        for (dev, prec) in cells_present:
            match = [r for r in ms if r["device"] == dev and r["precision"] == prec]
            if match:
                rows_ordered.append(match[0])
                labels.append(f"{dev}\n{prec}" + ("*" if match[0]["_placeholder"] else ""))

        if not rows_ordered:
            continue

        ys = [r["median_ms"] for r in rows_ordered]
        colors = [device_precision_color(r["device"], r["precision"]) for r in rows_ordered]
        hatches = ["//" if r["_placeholder"] else "" for r in rows_ordered]
        bars = ax.bar(range(len(ys)), ys, color=colors,
                      edgecolor="black", linewidth=0.5)
        for bar, h in zip(bars, hatches):
            bar.set_hatch(h)

        # Linear y-axis on purpose — log + per-panel scaling was making
        # 10ms-vs-9ms (within noise) look like a meaningful difference.
        ax.set_xticks(range(len(labels)))
        ax.set_xticklabels(labels, rotation=0, fontsize=8)
        ax.set_ylabel("median latency (ms)")
        ax.set_title(f"{model}   B={batch}, S={seq_len}")
        ax.grid(True, axis="y", alpha=0.3)

        for i, r in enumerate(rows_ordered):
            ax.text(i, r["median_ms"], f"{r['median_ms']:.2f}",
                    ha="center", va="bottom", fontsize=7)

    has_placeholder = any(r["_placeholder"] for r in pick)
    suptitle = f"Cross-precision latency comparison at B={batch}, S={seq_len}"
    if has_placeholder:
        suptitle += "   (* = FPGA placeholder, hatched)"
    fig.suptitle(suptitle, y=1.02)
    fig.tight_layout()
    fig.savefig(out_path, bbox_inches="tight", dpi=140)
    plt.close(fig)


# -----------------------------------------------------------------------------
# Utilization, phase decomposition, MLA decode bandwidth
# (figures driven by the new per-row fields added to JSONL output)
# -----------------------------------------------------------------------------

def fig_model_comparison_bars(rows, out_path,
                              batch: int = 16, seq_len: int = 1024,
                              precision: str = "bf16",
                              device: str = "cuda"):
    """Cross-model latency at one fixed (device, precision, batch, seq_len).
    Five bars, one per model, ordered by variant + size for sensible reading.

    This is the chart that answers "which architecture is fastest at this
    workload" — which is the model-axis story you actually care about.
    Differs from `fig_precision_bars`, which compares precisions within a
    model (less interesting if precision-axis isn't the headline)."""
    pick = [r for r in rows
            if r["batch"] == batch and r["seq_len"] == seq_len
            and r["device"] == device and r["precision"] == precision]
    if not pick:
        print(f"[plot] fig_model_comparison_bars: no rows at "
              f"B={batch} S={seq_len} {device}/{precision}; skipping.")
        return

    # Order: by variant (MHA, GQA, MQA, MLA) then by hidden_size, with
    # known model-pretty-names from _MODEL_DIMS.
    def sort_key(r):
        m = r["model"]
        d = _MODEL_DIMS.get(m, {})
        return (
            _VARIANT_ORDER.index(d.get("variant", "ZZZ")) if d.get("variant") in _VARIANT_ORDER else 99,
            d.get("H", 0),
        )
    pick = sorted(pick, key=sort_key)

    labels  = [_MODEL_DIMS.get(r["model"], {}).get("label", r["model"]) for r in pick]
    ys      = [r["median_ms"] for r in pick]
    # Color by variant so the architectural axis is visible at a glance.
    colors  = [_VARIANT_COLOR.get(_MODEL_DIMS.get(r["model"], {}).get("variant"), "#888")
               for r in pick]

    fig, ax = plt.subplots(figsize=(max(8, 1.7 * len(pick)), 5.0))
    bars = ax.bar(range(len(ys)), ys, color=colors,
                  edgecolor="black", linewidth=0.5, width=0.65)

    # Annotate each bar with both ms and tokens/s.
    for i, r in enumerate(pick):
        ms = r["median_ms"]
        tps = r.get("tokens_per_s", (batch * seq_len) / (ms / 1000.0))
        ax.text(i, ms, f"{ms:.2f} ms\n({tps/1e6:.2f} M tok/s)",
                ha="center", va="bottom", fontsize=8)

    ax.set_xticks(range(len(labels)))
    ax.set_xticklabels(labels, rotation=15, ha="right", fontsize=9)
    ax.set_ylabel("median latency (ms)")
    ax.set_title(f"Cross-model latency comparison at B={batch}, S={seq_len}  "
                 f"({device.upper()} · {precision})\n"
                 "Lower is better. Bars colored by attention variant.")
    ax.grid(True, axis="y", alpha=0.3)
    ax.set_ylim(0, max(ys) * 1.18 if ys else 1)

    # Variant legend — only the variants actually shown.
    from matplotlib.patches import Patch
    variants_shown = []
    for r in pick:
        v = _MODEL_DIMS.get(r["model"], {}).get("variant")
        if v and v not in variants_shown:
            variants_shown.append(v)
    handles = [Patch(facecolor=_VARIANT_COLOR[v], edgecolor="black",
                     linewidth=0.4, label=v) for v in variants_shown]
    if handles:
        ax.legend(handles=handles, loc="upper right",
                  title="variant", title_fontsize=8, fontsize=8)

    fig.tight_layout()
    fig.savefig(out_path, bbox_inches="tight", dpi=140)
    plt.close(fig)


def fig_utilization_per_cell(rows, out_path,
                             batch: int = 16, seq_len: int = 1024):
    """Grouped bar chart of achieved/peak utilization at a reference cell.
    Reads `utilization_pct` straight from the JSONL — it's recorded per-row
    by run_bench.py using src/bench/peaks.py.

    Y-axis is in percent (0-100). Bars hover near 100% for a kernel that's
    saturating its peak, and well below for the cells we know aren't well-
    tuned (e.g. torchao W8A8 dispatch overhead, or single-layer prefill at
    7B which leaves significant per-call overhead unamortized).
    """
    pick = [r for r in rows
            if r["batch"] == batch and r["seq_len"] == seq_len
            and r.get("utilization_pct") is not None]
    if not pick:
        print(f"[plot] fig_utilization_per_cell: no rows with utilization_pct "
              f"at B={batch} S={seq_len}; skipping.")
        return

    models = sorted({r["model"] for r in pick})
    fig, axes = plt.subplots(1, len(models), figsize=(5.0 * len(models), 4.2),
                             sharey=True)
    if len(models) == 1:
        axes = [axes]

    _DEV_RANK = {"cpu": 0, "cuda": 1, "fpga_u280": 2}
    _PREC_RANK = {
        "fp32": 0, "fp16": 1, "bf16": 2,
        "int8": 10, "int8_compiled": 11, "int4": 12,
        "int8_wo": 20, "int4_torchao": 21, "nf4": 22, "int8_bnb": 23,
    }

    for ax, model in zip(axes, models):
        ms = [r for r in pick if r["model"] == model]
        cells = sorted(
            {(r["device"], r["precision"]) for r in ms},
            key=lambda dp: (_DEV_RANK.get(dp[0], 99), _PREC_RANK.get(dp[1], 99)),
        )
        if not cells:
            continue
        utils, labels, colors = [], [], []
        for (dev, prec) in cells:
            match = [r for r in ms if r["device"] == dev and r["precision"] == prec]
            if not match:
                continue
            r = match[0]
            utils.append(r["utilization_pct"] * 100.0)     # to percent
            labels.append(f"{dev}\n{prec}")
            colors.append(device_precision_color(dev, prec))

        bars = ax.bar(range(len(utils)), utils, color=colors,
                      edgecolor="black", linewidth=0.5)
        ax.axhline(100, color="gray", linestyle="--", linewidth=0.8, alpha=0.6)
        ax.set_xticks(range(len(labels)))
        ax.set_xticklabels(labels, rotation=0, fontsize=8)
        ax.set_title(f"{model}  B={batch}, S={seq_len}")
        ax.grid(True, axis="y", alpha=0.3)
        ax.set_ylim(0, max(105, max(utils) * 1.15) if utils else 100)
        for i, u in enumerate(utils):
            ax.text(i, u, f"{u:.1f}%", ha="center", va="bottom", fontsize=7)

    axes[0].set_ylabel("Utilization (% of platform peak)")
    fig.suptitle("Achieved compute / device peak per (model, device, precision) "
                 f"at B={batch}, S={seq_len}", y=1.02)
    fig.tight_layout()
    fig.savefig(out_path, bbox_inches="tight", dpi=140)
    plt.close(fig)


def fig_phase_decomposition(rows, out_path,
                            batch: int = 16, seq_len: int = 1024):
    """Compute + output time per cell, with synthetic-input prep ("staging")
    *excluded* from the visualization.

    The raw `phase_staging_ms` field captures input gen + H2D + sync. In our
    benchmark harness the dominant cost is single-threaded `torch.randn`
    generating a fresh CPU tensor each call (256 MB at B=16 S=1024 BF16
    takes ~200ms). That's a benchmark-harness artifact, not what a real
    inference engine pays — a serving system has the input tensor pre-built
    and only pays the actual H2D copy. Including it in the figure squashes
    the inference-relevant phases (compute, output D2H) into invisible
    slivers and gives a misleading "10× more time in staging than compute"
    impression.

    What we plot here: bars sized by **compute + output only**. The
    excluded staging time is reported in the title for full transparency,
    so a reviewer can reconstruct the total wall time if needed.

    The teammate-CSV `phase_staging` column still carries the raw value;
    the `perf_results.csv` exporter is unaffected. This is purely a
    visualization choice on the headline figure.
    """
    pick = [r for r in rows
            if r["batch"] == batch and r["seq_len"] == seq_len
            and r.get("phase_compute_ms") is not None]
    if not pick:
        print(f"[plot] fig_phase_decomposition: no rows with phase_*_ms "
              f"at B={batch} S={seq_len}; skipping.")
        return

    _DEV_RANK = {"cpu": 0, "cuda": 1, "fpga_u280": 2}
    _PREC_RANK = {
        "fp32": 0, "fp16": 1, "bf16": 2,
        "int8": 10, "int8_compiled": 11, "int4": 12,
        "int8_wo": 20, "int4_torchao": 21, "nf4": 22, "int8_bnb": 23,
    }
    pick = sorted(pick, key=lambda r: (
        r["model"], _DEV_RANK.get(r["device"], 99),
        _PREC_RANK.get(r["precision"], 99)))

    labels  = [f"{r['model']}\n{r['device']}·{r['precision']}" for r in pick]
    staging = [r.get("phase_staging_ms", 0) or 0 for r in pick]
    compute = [r.get("phase_compute_ms", 0) or 0 for r in pick]
    output  = [r.get("phase_output_ms", 0) or 0 for r in pick]

    n = len(pick)
    fig, ax = plt.subplots(figsize=(max(8, n * 0.55), 5.5))
    x = np.arange(n)
    # Bars: compute (orange) + output D2H (green). Staging is excluded
    # from the visual but reported in the title.
    ax.bar(x, compute,
           label="compute (median per-iter)",
           color="#ff8b6b", edgecolor="black", linewidth=0.4)
    ax.bar(x, output, bottom=compute,
           label="output (D2H of one output tensor)",
           color="#83d68a", edgecolor="black", linewidth=0.4)

    # Annotate each bar with compute + output total in ms.
    for xi, (c, o) in enumerate(zip(compute, output)):
        total = c + o
        ax.text(xi, total, f"{total:.1f}", ha="center", va="bottom", fontsize=7)

    ax.set_xticks(x)
    ax.set_xticklabels(labels, rotation=60, ha="right", fontsize=7)
    ax.set_ylabel("time (ms) — compute + output only")
    median_staging = float(np.median(staging)) if staging else 0.0
    ax.set_title(
        f"Inference wall-time breakdown at B={batch}, S={seq_len}\n"
        f"Synthetic input-gen ('staging') excluded from bars — that cost is a "
        f"harness artifact (CPU torch.randn dominates).\n"
        f"For reference: median staging across cells = {median_staging:.1f} ms; "
        f"raw values are in the JSONL `phase_staging_ms` field.")
    ax.legend(loc="upper right", fontsize=8)
    ax.grid(True, axis="y", alpha=0.3)
    fig.tight_layout()
    fig.savefig(out_path, bbox_inches="tight", dpi=140)
    plt.close(fig)


def fig_mla_decode_kv_traffic(out_path):
    """Static plot — bytes per decode step from the KV-cache slice alone,
    across the 5-model lineup, at S_total = 4096 BF16. This is the headline
    "MLA wins decode" chart.

    Computed analytically from each model's dims (no runs needed); the
    actual decode-bench numbers should track these ratios within the
    weight-load constant. Plotted on a log y-axis because MLA's cache is
    ~2 orders of magnitude smaller than MHA's at large H_q.
    """
    s_total = 4096
    elem_bytes = 2

    models = ["llama2_7b_mha", "starcoder_7b_mqa", "mistral_7b_gqa",
              "llama31_70b_gqa", "deepseek_v2_mla"]
    labels, bytes_per_token, total_cache_bytes, colors = [], [], [], []
    for m in models:
        if m not in _MODEL_DIMS:
            continue
        d = _MODEL_DIMS[m]
        per_tok = _kv_bytes_per_token(m, elem_bytes)
        labels.append(d["label"])
        bytes_per_token.append(per_tok)
        total_cache_bytes.append(per_tok * s_total)
        colors.append(_VARIANT_COLOR.get(d.get("variant", "MHA"), "#999"))

    fig, ax = plt.subplots(figsize=(9, 5.4))
    x = np.arange(len(labels))
    width = 0.4

    bars1 = ax.bar(x - width/2, bytes_per_token, width=width,
                   color=colors, edgecolor="black", linewidth=0.5,
                   label="bytes per token (cache slice)")
    bars2 = ax.bar(x + width/2, total_cache_bytes, width=width,
                   color=colors, edgecolor="black", linewidth=0.5,
                   alpha=0.55, hatch="//",
                   label=f"total cache @ S={s_total}")

    for bar, val in zip(bars1, bytes_per_token):
        ax.text(bar.get_x() + bar.get_width()/2, val,
                f"{val} B" if val < 1024 else f"{val/1024:.1f} KB",
                ha="center", va="bottom", fontsize=7)
    for bar, val in zip(bars2, total_cache_bytes):
        ax.text(bar.get_x() + bar.get_width()/2, val,
                _humanize_bytes(val), ha="center", va="bottom", fontsize=7)

    ax.set_yscale("log")
    ax.set_xticks(x)
    ax.set_xticklabels(labels, rotation=20, ha="right", fontsize=9)
    ax.set_ylabel("bytes (log)")
    ax.set_title("KV-cache HBM traffic per decode step\n"
                 "(MLA stores only c_kv + K_R per token; MHA/MQA/GQA store full K + V)")
    ax.legend(loc="upper right", fontsize=9)
    ax.grid(True, axis="y", alpha=0.3, which="both")

    fig.tight_layout()
    fig.savefig(out_path, bbox_inches="tight", dpi=140)
    plt.close(fig)


# -----------------------------------------------------------------------------
# Decode-phase plots
# -----------------------------------------------------------------------------

# Hardcoded model dims so we can compute analytical decode FLOPs/bytes
# without having to thread them through the JSONL meta block.
#
# Standard models carry the (H, H_q, H_kv, D) tuple. MLA carries additional
# fields (q_lora_rank, kv_lora_rank, qk_nope_head_dim, qk_rope_head_dim,
# v_head_dim) needed for its non-standard FLOPs and per-token cache
# accounting. The "variant" key drives the per-step formulas below.
_MODEL_DIMS = {
    # Tier 1 — 7B variant comparison
    "llama2_7b_mha":    dict(variant="MHA", H=4096, H_q=32, H_kv=32, D=128,
                             label="Llama-2-7B (MHA)"),
    "mistral_7b_gqa":   dict(variant="GQA", H=4096, H_q=32, H_kv=8,  D=128,
                             label="Mistral-7B (GQA)"),
    "starcoder_7b_mqa": dict(variant="MQA", H=4096, H_q=32, H_kv=1,  D=128,
                             label="StarCoder-7B (MQA)"),
    # Tier 2 — large-model SOTA face-off
    "llama31_70b_gqa":  dict(variant="GQA", H=8192, H_q=64, H_kv=8,  D=128,
                             label="Llama-3.1-70B (GQA)"),
    "deepseek_v2_mla":  dict(variant="MLA", H=5120, H_q=128, H_kv=128,
                             D=192,                       # qk head_dim
                             v_head_dim=128,
                             qk_nope_head_dim=128,
                             qk_rope_head_dim=64,
                             q_lora_rank=1536,
                             kv_lora_rank=512,
                             label="DeepSeek-V2 (MLA)"),
}


def _decode_flops_per_step(model: str, S_total: int, batch: int = 1) -> int:
    """Analytical FLOPs for one decode STEP (one batched forward call) at
    cache length S_total. With B=1 this is per-token; with B>1 the call
    produces B new tokens at once and the FLOPs scale linearly with B.
    """
    d = _MODEL_DIMS[model]
    if d.get("variant") == "MLA":
        return _decode_flops_per_step_mla(d, S_total, batch)
    H, H_q, H_kv, D = d["H"], d["H_q"], d["H_kv"], d["D"]
    # Standard MHA/GQA/MQA decode: 4 projections + QK^T + AV.
    # All FLOPs scale with B (each batch element gets its own Q/K/V/O work
    # and its own attention against its own cache).
    flops_q  = 2 * batch * H * H_q  * D
    flops_k  = 2 * batch * H * H_kv * D
    flops_v  = 2 * batch * H * H_kv * D
    flops_o  = 2 * batch * H_q * D * H
    flops_qk = 2 * batch * H_q * 1 * S_total * D
    flops_av = 2 * batch * H_q * 1 * S_total * D
    return flops_q + flops_k + flops_v + flops_o + flops_qk + flops_av


def _decode_flops_per_step_mla(d: dict, S_total: int, batch: int) -> int:
    """MLA decode FLOPs with **absorbed attention** — what the proper MLA
    inference path actually does. Per step:

      - Project Q for the new token: (q_a 5120→1536) + (q_b 1536→H_q*qk_dim)
      - Project KV for the new token: kv_a (H→lora+rope) — TINY because
        it produces just (lora_rank + qk_rope_head_dim) per token, no
        full per-head decompression at decode time.
      - Compute Q @ W^UK in latent space (per query head, small matmul)
      - Score = Q_latent @ c_kv^T + Q_rope @ K_R^T (against full cache)
      - softmax then partial = P @ c_kv (in latent space)
      - Output = partial @ W^UV^T (per query head)
      - O proj
    """
    H = d["H"]
    H_q = d["H_q"]
    qk_nope = d["qk_nope_head_dim"]
    qk_rope = d["qk_rope_head_dim"]
    qk_dim = qk_nope + qk_rope                        # 192
    v_dim = d["v_head_dim"]                           # 128
    q_lora = d.get("q_lora_rank")
    kv_lora = d["kv_lora_rank"]

    # Q projection (with optional q_lora down-up)
    if q_lora is not None:
        flops_q = 2 * batch * (H * q_lora + q_lora * H_q * qk_dim)
    else:
        flops_q = 2 * batch * H * H_q * qk_dim

    # KV projection — combined (kv_lora + qk_rope) output
    flops_kv = 2 * batch * H * (kv_lora + qk_rope)

    # Absorbed Q-side latent projection (Q_nope @ W^UK), per head
    flops_q_absorb = 2 * batch * H_q * qk_nope * kv_lora

    # Score: nope channel against latent cache + rope channel against K_R
    flops_score_nope = 2 * batch * H_q * 1 * S_total * kv_lora
    flops_score_rope = 2 * batch * H_q * 1 * S_total * qk_rope

    # P @ c_kv in latent space, then @ W^UV^T
    flops_pv_latent = 2 * batch * H_q * 1 * S_total * kv_lora
    flops_v_absorb = 2 * batch * H_q * kv_lora * v_dim

    # Output projection
    flops_o = 2 * batch * H_q * v_dim * H

    return (flops_q + flops_kv + flops_q_absorb
            + flops_score_nope + flops_score_rope
            + flops_pv_latent + flops_v_absorb + flops_o)


def _decode_bytes_per_step(model: str, S_total: int, batch: int = 1,
                           elem_bytes: int = 2) -> int:
    """Analytical bytes moved for one decode step at cache length S_total
    and batch size `batch`. Weights are loaded ONCE per call regardless of
    batch (they're shared across batch elements). Activations and KV cache
    scale with batch.
    """
    d = _MODEL_DIMS[model]
    if d.get("variant") == "MLA":
        return _decode_bytes_per_step_mla(d, S_total, batch, elem_bytes)
    H, H_q, H_kv, D = d["H"], d["H_q"], d["H_kv"], d["D"]
    # Weight bytes: shared across the batch — one load per call.
    bytes_w = (H * H_q * D + 2 * H * H_kv * D + H_q * D * H) * elem_bytes
    # Per-sequence bytes: input act, KV-cache read, KV-cache write, output act.
    bytes_per_seq = (
        H                                         # input activation
        + 2 * S_total * H_kv * D                   # full K, V read
        + 2 *           H_kv * D                   # new K, V append
        + H                                        # output activation
    ) * elem_bytes
    return bytes_w + batch * bytes_per_seq


def _decode_bytes_per_step_mla(d: dict, S_total: int, batch: int,
                               elem_bytes: int) -> int:
    """MLA decode bytes — this is where MLA wins.

    Cache stores only c_kv (kv_lora_rank) + K_R (qk_rope_head_dim) per
    token, regardless of head count. For DeepSeek-V2 that's 512 + 64 = 576
    dims/token instead of the 32768 dims/token (128 heads × 128 head_dim ×
    2 for K and V) that an equivalent dense MHA cache would need —
    a ~57× reduction.
    """
    H = d["H"]
    H_q = d["H_q"]
    qk_nope = d["qk_nope_head_dim"]
    qk_rope = d["qk_rope_head_dim"]
    qk_dim = qk_nope + qk_rope
    v_dim = d["v_head_dim"]
    q_lora = d.get("q_lora_rank")
    kv_lora = d["kv_lora_rank"]

    # Weight bytes: q projections, kv projections (combined), o.
    if q_lora is not None:
        w_q = H * q_lora + q_lora * H_q * qk_dim
    else:
        w_q = H * H_q * qk_dim
    w_kv = H * (kv_lora + qk_rope) + kv_lora * H_q * (qk_nope + v_dim)
    w_o = H_q * v_dim * H
    bytes_w = (w_q + w_kv + w_o) * elem_bytes

    # Per-sequence bytes: input act, latent cache read (c_kv + K_R),
    # cache append (one new latent token), output act.
    bytes_per_seq = (
        H                                         # input activation
        + S_total * (kv_lora + qk_rope)           # latent cache read
        +           (kv_lora + qk_rope)           # new latent token append
        + H                                        # output activation
    ) * elem_bytes
    return bytes_w + batch * bytes_per_seq


def _kv_bytes_per_token(model: str, elem_bytes: int = 2) -> int:
    """How many cache bytes one token occupies. Used by the new MLA-vs-rest
    bandwidth-comparison plot. For MHA/MQA/GQA: 2 × H_kv × D × elem_bytes.
    For MLA: (kv_lora_rank + qk_rope_head_dim) × elem_bytes."""
    d = _MODEL_DIMS[model]
    if d.get("variant") == "MLA":
        return (d["kv_lora_rank"] + d["qk_rope_head_dim"]) * elem_bytes
    return 2 * d["H_kv"] * d["D"] * elem_bytes


# Backward-compatible aliases (older callers still expecting per-token names).
def _decode_flops_per_token(model, S_total):
    return _decode_flops_per_step(model, S_total, batch=1)


def _decode_bytes_per_token(model, S_total, elem_bytes=2):
    return _decode_bytes_per_step(model, S_total, batch=1, elem_bytes=elem_bytes)


# Variant ordering — the "attention compression" axis. MHA (largest KV) →
# GQA (grouped) → MQA (single KV head) → MLA (latent compression, different
# axis entirely but slots after MQA in the bandwidth-savings progression).
_VARIANT_ORDER = ["MHA", "GQA", "MQA", "MLA"]
_VARIANT_COLOR = {
    "MHA": plt.cm.Reds(0.75),
    "GQA": plt.cm.Reds(0.55),
    "MQA": plt.cm.Reds(0.35),
    # MLA gets a distinct hue (purple) because it's a different design axis
    # than the head-count progression — readers shouldn't mistake it for a
    # "more aggressive MQA".
    "MLA": plt.cm.Purples(0.65),
}


def _bf16_decode_rows_by_variant(decode_summary):
    """Return GPU-BF16 decode summary rows in MHA → GQA → MQA order."""
    bf16 = [r for r in decode_summary
            if r["device"] == "cuda" and r["precision"] == "bf16"]
    bf16.sort(key=lambda r: _VARIANT_ORDER.index(r["variant"]))
    return bf16

def fig_decode_variant_latency_bf16(decode_summary, out_path):
    """Plot 1 of the architectural-decode story.

    BF16 only. Y = average per-token decode latency (ms), derived from
    the end-to-end timed window: total_decode_ms / timed_tokens. Reported
    tok/s is per-batch-element-per-second (B / avg_per_token_ms × 1000).
    """
    rows = _bf16_decode_rows_by_variant(decode_summary)
    if not rows:
        print("[plot] fig_decode_variant_latency_bf16: no GPU BF16 decode rows.")
        return

    fig, ax = plt.subplots(figsize=(7, 5))
    labels  = [_MODEL_DIMS[r["model"]]["label"] for r in rows]
    ys      = [r["avg_per_token_ms"] for r in rows]
    colors  = [_VARIANT_COLOR[r["variant"]]      for r in rows]

    bars = ax.bar(range(len(rows)), ys, color=colors,
                  edgecolor="black", linewidth=0.6, width=0.55)

    # Numerical labels above each bar — show per-step ms and per-batch-element tok/s.
    for i, (r, val) in enumerate(zip(rows, ys)):
        B = int(r.get("batch", 1))
        per_step_tps = (B * 1000.0) / val if val > 0 else 0
        ax.text(i, val, f"{val:.3f} ms\n({per_step_tps:,.0f} tok/s, B={B})",
                ha="center", va="bottom", fontsize=9)

    # Speedup vs MHA, drawn under each bar
    base = ys[0]
    for i, val in enumerate(ys):
        if i == 0:
            tag = "1.00× (baseline)"
        else:
            tag = f"{base/val:.2f}× faster"
        ax.text(i, val * 0.05, tag, ha="center", va="bottom",
                fontsize=9, color="#222", fontweight="bold")

    s_total = rows[0]["s_init"] + rows[0]["tokens_decoded"]
    ax.set_xticks(range(len(rows)))
    ax.set_xticklabels(labels, fontsize=7)
    ax.set_ylabel("median per-token decode latency (ms)")
    ax.set_title(f"Decode latency by attention variant   "
                 f"(GPU L40S, BF16, S_total = {s_total})\n"
                 f"Lower is better. The ratio is the architectural KV-head reduction in action.")
    ax.grid(True, axis="y", alpha=0.3)
    ax.set_ylim(0, max(ys) * 1.18)

    fig.tight_layout()
    fig.savefig(out_path, bbox_inches="tight", dpi=140)
    plt.close(fig)


def fig_decode_kv_cache_by_variant(decode_summary, out_path, num_layers: int = 32):
    """Plot 2 of the architectural-decode story.

    Bar chart, X = attention variant (MHA/GQA/MQA), Y = KV cache bytes at
    end of decode (log scale). Shows the 4×, 32× memory reduction MQA/GQA
    deliver vs MHA — independent of compute precision.
    """
    rows = _bf16_decode_rows_by_variant(decode_summary)
    if not rows:
        print("[plot] fig_decode_kv_cache_by_variant: no GPU BF16 decode rows.")
        return

    fig, ax = plt.subplots(figsize=(8, 5.2))

    labels      = [_MODEL_DIMS[r["model"]]["label"] for r in rows]
    s_total     = [r["kv_cache_seq_len_final"]      for r in rows]
    bytes_layer = [r["kv_cache_bytes_final"]        for r in rows]
    bytes_full  = [b * num_layers                   for b in bytes_layer]
    colors      = [_VARIANT_COLOR[r["variant"]]      for r in rows]

    x = list(range(len(rows)))
    width = 0.4
    bars1 = ax.bar([i - width/2 for i in x], bytes_layer,
                   width=width, color=colors,
                   edgecolor="black", linewidth=0.5,
                   label="per-layer (this benchmark scope)")
    bars2 = ax.bar([i + width/2 for i in x], bytes_full,
                   width=width, color=colors,
                   edgecolor="black", linewidth=0.5, alpha=0.5, hatch="//",
                   label=f"full model (× {num_layers} layers)")

    for bar, val in zip(bars1, bytes_layer):
        ax.text(bar.get_x() + bar.get_width()/2, val,
                _humanize_bytes(val), ha="center", va="bottom", fontsize=8)
    for bar, val in zip(bars2, bytes_full):
        ax.text(bar.get_x() + bar.get_width()/2, val,
                _humanize_bytes(val), ha="center", va="bottom", fontsize=8)

    # Speedup-style ratios vs MHA, on the per-layer bars
    if rows:
        base = bytes_layer[0]
        for i, val in enumerate(bytes_layer):
            if i == 0:
                continue
            ax.text(i - width/2, val * 1.4, f"÷ {base/val:.0f}",
                    ha="center", va="bottom", fontsize=10,
                    fontweight="bold", color="#225522")

    ax.set_yscale("log")
    ax.set_xticks(x)
    ax.set_xticklabels([f"{lbl}\nS={st}" for lbl, st in zip(labels, s_total)],
                       fontsize=7)
    ax.set_ylabel("KV cache size (bytes, log)")

    # Title adapts to which variants are actually present in the data,
    # so it doesn't lie when a subset of the lineup was decode-benchmarked.
    variants_present = sorted({r["variant"] for r in rows},
                              key=lambda v: _VARIANT_ORDER.index(v) if v in _VARIANT_ORDER else 99)
    if len(variants_present) >= 3:
        comparison = " vs ".join(variants_present)
        subtitle = f"{comparison} architectural difference"
    elif len(variants_present) == 2:
        subtitle = f"{variants_present[0]} vs {variants_present[1]} cache footprint"
    else:
        subtitle = f"{variants_present[0] if variants_present else 'N/A'} cache footprint"
    ax.set_title(f"KV cache footprint by attention variant   "
                 f"(at end of decode, BF16 cache)\n{subtitle}",
                 fontsize=11)
    ax.legend(loc="upper right", fontsize=9)
    ax.grid(True, axis="y", alpha=0.3, which="both")

    fig.tight_layout()
    fig.savefig(out_path, bbox_inches="tight", dpi=140)
    plt.close(fig)


def _humanize_bytes(b: float) -> str:
    if b >= 1e9: return f"{b/1e9:.2f} GB"
    if b >= 1e6: return f"{b/1e6:.1f} MB"
    if b >= 1e3: return f"{b/1e3:.1f} KB"
    return f"{int(b)} B"


def fig_decode_roofline(decode_summary, out_path):
    """Plot 3 of the architectural-decode story — same axes/conventions as
    the prefill roofline plots, but at decode shapes.

    Decode arithmetic intensity is dramatically lower than prefill (decode
    reads weights + KV cache for each token of work); points sit deep in
    the memory-bound regime. The MHA→GQA→MQA progression walks the points
    rightward (higher AI) and upward (higher achieved throughput) along
    the same memory-bandwidth diagonal.
    """
    rows = _bf16_decode_rows_by_variant(decode_summary)
    if not rows:
        print("[plot] fig_decode_roofline: no GPU BF16 decode rows.")
        return

    # Each variant has one canonical representative; for GQA we only keep
    # the 70B point (drop mistral_7b_gqa) so the plot doesn't show two
    # GQA dots that say the same thing.
    rows = [r for r in rows if r["model"] != "mistral_7b_gqa"]

    peak_tops = PLATFORM_PEAK_TOPS[("cuda", "bf16")]
    bw        = PLATFORM_BW_GBPS["cuda"] * 1e9
    ai_ridge  = peak_tops / bw

    fig, ax = plt.subplots(figsize=(8, 5.6))

    # Roofline ridge
    ai_range  = np.logspace(-1, 4, 400)
    mem_bound = ai_range * bw
    achievable = np.minimum(mem_bound, np.full_like(mem_bound, peak_tops)) / 1e12
    ridge_color = device_precision_color("cuda", "bf16")
    ax.plot(ai_range, achievable, color=ridge_color, linewidth=2.5,
            label="GPU L40S BF16 ceiling")
    ax.axvline(ai_ridge, color="gray", linestyle="--", alpha=0.5, linewidth=0.9)
    ax.axhline(peak_tops / 1e12, color="gray", linestyle="--",
               alpha=0.5, linewidth=0.9)
    ax.plot([ai_ridge], [peak_tops / 1e12], marker="D", color=ridge_color,
            markeredgecolor="black", markersize=9, zorder=4)
    ax.annotate(f"ridge · AI={ai_ridge:.0f}",
                xy=(ai_ridge, peak_tops / 1e12),
                xytext=(10, -12), textcoords="offset points",
                fontsize=8, color=ridge_color, fontweight="bold")

    # Shade memory-bound vs compute-bound regimes
    ax.axvspan(ai_range[0], ai_ridge, color="blue", alpha=0.05)
    ax.axvspan(ai_ridge, ai_range[-1], color="red",  alpha=0.05)

    # Place the measured decode points using the avg-per-step time from
    # the end-to-end window.
    for r in rows:
        S_total = r["kv_cache_seq_len_final"]
        B       = int(r.get("batch", 1))
        flops   = _decode_flops_per_step(r["model"], S_total, batch=B)
        bytes_  = _decode_bytes_per_step(r["model"], S_total, batch=B, elem_bytes=2)
        ai      = flops / bytes_
        ach     = (flops / (r["avg_per_token_ms"] / 1000.0)) / 1e12   # TFLOPs/s
        ax.scatter([ai], [ach],
                   color=_VARIANT_COLOR[r["variant"]],
                   s=140, edgecolor="black", linewidth=0.8, zorder=6,
                   label=f"{_MODEL_DIMS[r['model']]['label']}  "
                         f"B={B}  AI={ai:.2f}, ach={ach:.2f} TFLOP/s")
        ax.annotate(r["variant"],
                    xy=(ai, ach),
                    xytext=(8, 6), textcoords="offset points",
                    fontsize=10, fontweight="bold",
                    color=_VARIANT_COLOR[r["variant"]])

    # Annotate regimes
    ax.text(0.015, 0.06, "memory-bound", transform=ax.transAxes,
            fontsize=10, color="navy", alpha=0.7)
    ax.text(0.55, 0.06, "compute-bound", transform=ax.transAxes,
            fontsize=10, color="darkred", alpha=0.7)

    ax.set_xscale("log")
    ax.set_yscale("log")
    ax.set_xlabel("Arithmetic intensity (FLOPs / byte)")
    ax.set_ylabel("Achieved throughput (TFLOPs/s)")
    s_total = rows[0]["kv_cache_seq_len_final"]
    ax.set_title(f"Decode roofline @ S = {s_total}, BF16  "
                 "(all three points are deep in the memory-bound regime)")
    ax.grid(True, alpha=0.3, which="both")
    ax.legend(loc="lower right", fontsize=8, framealpha=0.95)
    fig.tight_layout()
    fig.savefig(out_path, bbox_inches="tight", dpi=140)
    plt.close(fig)


def _find_prefill_at(prefill_rows, model: str, batch: int, seq_len: int):
    """Return the prefill row for (model, batch, seq_len) on cuda+bf16, or
    the row at the seq_len closest to the requested one if exact isn't there.
    Used by the combined-workload roofline."""
    pool = [r for r in prefill_rows
            if r["model"] == model and r["batch"] == batch
            and r["device"] == "cuda" and r["precision"] == "bf16"]
    if not pool:
        return None
    exact = [r for r in pool if r["seq_len"] == seq_len]
    if exact:
        return exact[0]
    # closest by absolute distance in log space
    return min(pool, key=lambda r: abs(np.log(r["seq_len"]) - np.log(seq_len)))


def fig_workload_roofline(prefill_rows, decode_summary, out_path):
    """One roofline. Three circles. Each circle is the COMPLETE workload —
    prefill the prompt + decode N new tokens — for one architectural variant
    on GPU L40S BF16.

    AI = (total FLOPs over the whole workload) / (total bytes moved)
    Throughput = (total FLOPs) / (prefill_ms + N × per-token-decode-ms)

    This is the answer to 'where on the roofline does an actual LLM inference
    request live?' — and it consolidates the per-phase decomposition into
    one number per architecture, which is what serving systems care about.
    """
    decode_bf = _bf16_decode_rows_by_variant(decode_summary)
    if not decode_bf:
        print("[plot] fig_workload_roofline: no GPU BF16 decode rows.")
        return

    # Each variant has one canonical representative; drop mistral_7b_gqa so
    # only the 70B GQA point remains.
    decode_bf = [r for r in decode_bf if r["model"] != "mistral_7b_gqa"]

    peak    = PLATFORM_PEAK_TOPS[("cuda", "bf16")]
    bw      = PLATFORM_BW_GBPS["cuda"] * 1e9
    ai_ridge = peak / bw
    peak_tflops = peak / 1e12
    ridge_color = device_precision_color("cuda", "bf16")

    fig, ax = plt.subplots(figsize=(9, 6))

    # Ridge
    ai_range = np.logspace(-1, 4.5, 400)
    achievable = np.minimum(ai_range * bw, peak) / 1e12
    ax.plot(ai_range, achievable, color=ridge_color, linewidth=2.5,
            label="L40S BF16 ceiling")
    ax.axvline(ai_ridge, color="gray", linestyle="--", alpha=0.5, linewidth=0.9)
    ax.axhline(peak_tflops, color="gray", linestyle="--", alpha=0.5, linewidth=0.9)
    ax.plot([ai_ridge], [peak_tflops], marker="D", color=ridge_color,
            markeredgecolor="black", markersize=9, zorder=4)
    ax.annotate(f"ridge · AI={ai_ridge:.0f}",
                xy=(ai_ridge, peak_tflops), xytext=(10, -12),
                textcoords="offset points",
                fontsize=8, color=ridge_color, fontweight="bold")

    # Regimes
    ax.axvspan(ai_range[0], ai_ridge, color="blue", alpha=0.06)
    ax.axvspan(ai_ridge, ai_range[-1], color="red", alpha=0.06)
    ax.text(0.025, 0.06, "memory-bound", transform=ax.transAxes,
            fontsize=10, color="navy", alpha=0.7)
    ax.text(0.55, 0.06, "compute-bound", transform=ax.transAxes,
            fontsize=10, color="darkred", alpha=0.7)

    s_prompt_used = None
    n_used = None

    batch_used = None

    for d_row in decode_bf:
        model     = d_row["model"]
        variant   = d_row["variant"]
        S_prompt  = int(d_row["s_init"])
        N         = int(d_row["tokens_decoded"])
        B         = int(d_row.get("batch", 1))
        # End-to-end decode wall time directly from the JSONL — no need to
        # multiply per-step by N anymore (we don't time per-step).
        decode_ms_total = float(d_row["total_decode_ms"])

        # 1. Prefill cost. Try to find prefill data at the SAME batch and S
        #    as the decode setup. Falls back to closest seq_len if exact
        #    isn't there. If the precise batch wasn't measured, fall back
        #    to whatever batch we have and scale FLOPs/bytes accordingly.
        p_row = _find_prefill_at(prefill_rows, model, batch=B, seq_len=S_prompt)
        if p_row is None:
            # No prefill at this batch — try B=1, scale up.
            p_row = _find_prefill_at(prefill_rows, model, batch=1, seq_len=S_prompt)
            if p_row is None:
                print(f"[plot] workload_roofline: no prefill data for {model}; skipping.")
                continue
            prefill_flops = float(p_row["flops"]) * B
            prefill_bytes = float(p_row["bytes_moved"]) * B
            prefill_ms    = float(p_row["median_ms"]) * B
        else:
            prefill_flops = float(p_row["flops"])
            prefill_bytes = float(p_row["bytes_moved"])
            prefill_ms    = float(p_row["median_ms"])

        # 2. Decode cost. Sum analytical FLOPs/bytes over the N steps (cache
        #    grows by one each step). Each step's FLOPs/bytes scale with B.
        decode_flops_total = 0
        decode_bytes_total = 0
        for t in range(N):
            S_now = S_prompt + t
            decode_flops_total += _decode_flops_per_step(model, S_now, batch=B)
            decode_bytes_total += _decode_bytes_per_step(model, S_now, batch=B)
        # decode_ms_total already pulled directly from the JSONL above.

        # 3. Combine.
        total_flops = prefill_flops + decode_flops_total
        total_bytes = prefill_bytes + decode_bytes_total
        total_ms    = prefill_ms + decode_ms_total

        ai      = total_flops / max(1.0, total_bytes)
        achieved_tflops = (total_flops / (total_ms / 1000.0)) / 1e12

        ax.scatter([ai], [achieved_tflops],
                   color=_VARIANT_COLOR[variant],
                   marker="o", s=240,
                   edgecolors="black", linewidth=1.0, zorder=8,
                   label=f"{_MODEL_DIMS[model]['label']}  "
                         f"B={B}  AI={ai:.2f}, ach={achieved_tflops:.2f} TFLOPs/s, "
                         f"total={total_ms:.0f} ms")
        ax.annotate(variant,
                    xy=(ai, achieved_tflops), xytext=(10, 10),
                    textcoords="offset points",
                    fontsize=11, fontweight="bold",
                    color=_VARIANT_COLOR[variant])

        s_prompt_used = S_prompt
        n_used = N
        batch_used = B

    ax.set_xscale("log")
    ax.set_yscale("log")
    ax.set_xlabel("Arithmetic intensity (FLOPs / byte)")
    ax.set_ylabel("Achieved throughput (TFLOPs/s)")
    title = "End-to-end attention workload roofline  (GPU L40S, BF16)"
    if s_prompt_used is not None:
        title += (f"\nB={batch_used}, prefill S={s_prompt_used} tokens, "
                  f"then decode +{n_used} tokens")
    ax.set_title(title)
    ax.grid(True, alpha=0.3, which="both")
    ax.legend(loc="lower right", fontsize=8, framealpha=0.95)

    fig.tight_layout()
    fig.savefig(out_path, bbox_inches="tight", dpi=140)
    plt.close(fig)


def fig_combined_prefill_decode_roofline(prefill_rows, decode_summary, out_path):
    """One roofline showing both prefill and decode points on the same axes.

    Prefill points anchor the right side (high AI, compute-bound regime,
    near the ceiling). Decode points anchor the left side (low AI, memory-
    bound regime, far below the ceiling). Same hardware, same model, two
    radically different operating regimes — visualized on a single chart.

    The 3-4 orders of magnitude in AI between prefill and decode is the
    most concrete possible answer to 'why are LLMs hard to serve.'
    """
    # GPU + BF16 only — the canonical reference path. Mixing precisions in
    # one chart muddies the regime comparison.
    prefill_bf = [r for r in prefill_rows
                  if r["device"] == "cuda" and r["precision"] == "bf16"
                  and r.get("variant") in _VARIANT_ORDER]
    decode_bf  = _bf16_decode_rows_by_variant(decode_summary)

    # Each variant has one canonical representative; drop mistral_7b_gqa so
    # only the 70B GQA point remains.
    prefill_bf = [r for r in prefill_bf if r["model"] != "mistral_7b_gqa"]
    decode_bf  = [r for r in decode_bf  if r["model"] != "mistral_7b_gqa"]

    if not prefill_bf and not decode_bf:
        print("[plot] fig_combined_prefill_decode_roofline: no GPU BF16 data.")
        return

    # For prefill, restrict to a single batch so the chart isn't a cloud.
    prefill_bf = _filter_fixed_batch(prefill_bf, ROOFLINE_BATCH)

    peak    = PLATFORM_PEAK_TOPS[("cuda", "bf16")]
    bw      = PLATFORM_BW_GBPS["cuda"] * 1e9
    ai_ridge = peak / bw
    peak_tflops = peak / 1e12
    ridge_color = device_precision_color("cuda", "bf16")

    fig, ax = plt.subplots(figsize=(10, 6))

    # --- Ridge ---
    ai_range  = np.logspace(-1, 4.5, 400)
    achievable = np.minimum(ai_range * bw, peak) / 1e12
    ax.plot(ai_range, achievable, color=ridge_color, linewidth=2.5,
            label="L40S BF16 ceiling")
    ax.axvline(ai_ridge, color="gray", linestyle="--", alpha=0.5, linewidth=0.9)
    ax.axhline(peak_tflops, color="gray", linestyle="--", alpha=0.5, linewidth=0.9)
    ax.plot([ai_ridge], [peak_tflops], marker="D", color=ridge_color,
            markeredgecolor="black", markersize=9, zorder=4)
    ax.annotate(f"ridge · AI={ai_ridge:.0f}",
                xy=(ai_ridge, peak_tflops), xytext=(10, -12),
                textcoords="offset points",
                fontsize=8, color=ridge_color, fontweight="bold")

    # Regime shading
    ax.axvspan(ai_range[0], ai_ridge, color="blue", alpha=0.06)
    ax.axvspan(ai_ridge, ai_range[-1], color="red", alpha=0.06)

    # --- Prefill points: marker = model shape, color = variant ---
    # Track which models we've already labeled so we annotate exactly once
    # per model (next to its largest-S point), not every dot.
    prefill_labeled = set()
    # Sort by descending seq_len so the largest-S point is hit first per model
    # — that's the rightmost, easiest-to-label position.
    for r in sorted(prefill_bf, key=lambda r: -r["seq_len"]):
        ai  = r["arithmetic_intensity"]
        ach = (r["flops"] / (r["median_ms"] / 1000.0)) / 1e12
        marker, label = _MODEL_MARKERS.get(r["model"], ("o", r["model"]))
        ax.scatter(ai, ach,
                   color=_VARIANT_COLOR[r["variant"]],
                   marker=marker, s=44, alpha=0.85,
                   edgecolors="black", linewidth=0.4, zorder=5)
        if r["model"] not in prefill_labeled:
            # Compact label for the prefill point — use a short alias.
            short = label.split()[0]   # "Llama-2-7B (MHA)" -> "Llama-2-7B"
            ax.annotate(f"{short}·prefill",
                        xy=(ai, ach), xytext=(8, -12),
                        textcoords="offset points",
                        fontsize=7, color=_VARIANT_COLOR[r["variant"]],
                        alpha=0.85)
            prefill_labeled.add(r["model"])

    # --- Decode points: big stars, color by variant, labeled ---
    for r in decode_bf:
        S_total = r["kv_cache_seq_len_final"]
        B       = int(r.get("batch", 1))
        flops   = _decode_flops_per_step(r["model"], S_total, batch=B)
        bytes_  = _decode_bytes_per_step(r["model"], S_total, batch=B, elem_bytes=2)
        ai      = flops / bytes_
        ach     = (flops / (r["avg_per_token_ms"] / 1000.0)) / 1e12
        ax.scatter([ai], [ach],
                   color=_VARIANT_COLOR[r["variant"]],
                   marker="*", s=300,
                   edgecolors="black", linewidth=0.9, zorder=8)
        ax.annotate(r["variant"],
                    xy=(ai, ach), xytext=(8, 8),
                    textcoords="offset points",
                    fontsize=10, fontweight="bold",
                    color=_VARIANT_COLOR[r["variant"]])

    # --- Region labels: "prefill" and "decode" annotations ---
    if prefill_bf:
        # Place near the prefill cluster
        prefill_xs = [r["arithmetic_intensity"] for r in prefill_bf]
        prefill_ys = [(r["flops"] / (r["median_ms"] / 1000.0)) / 1e12
                      for r in prefill_bf]
        cx, cy = max(prefill_xs) * 0.5, max(prefill_ys) * 1.6
        ax.text(cx, cy, "PREFILL\n(compute-bound)",
                ha="center", fontsize=11, color="darkred",
                fontweight="bold", alpha=0.85)
    if decode_bf:
        decode_xs = []
        decode_ys = []
        for r in decode_bf:
            S_total = r["kv_cache_seq_len_final"]
            B       = int(r.get("batch", 1))
            flops   = _decode_flops_per_step(r["model"], S_total, batch=B)
            bytes_  = _decode_bytes_per_step(r["model"], S_total, batch=B, elem_bytes=2)
            decode_xs.append(flops / bytes_)
            decode_ys.append((flops / (r["avg_per_token_ms"] / 1000.0)) / 1e12)
        cx, cy = min(decode_xs) * 0.6, min(decode_ys) * 0.4
        ax.text(cx, cy, "DECODE\n(memory-bound)",
                ha="center", fontsize=11, color="navy",
                fontweight="bold", alpha=0.85)

    # Legend: one entry per model present in either phase, using the
    # model's marker. Variant→color is conveyed by the marker fill.
    from matplotlib.lines import Line2D
    legend_handles = []
    models_seen = []
    for r in prefill_bf:
        if r["model"] not in models_seen:
            models_seen.append(r["model"])
    for r in decode_bf:
        if r["model"] not in models_seen:
            models_seen.append(r["model"])
    for m in models_seen:
        marker, label = _MODEL_MARKERS.get(m, ("o", m))
        # Variant color, falls back to grey if unknown.
        v = _MODEL_DIMS.get(m, {}).get("variant")
        color = _VARIANT_COLOR.get(v, "#888")
        legend_handles.append(
            Line2D([0], [0], marker=marker, color="none",
                   markerfacecolor=color, markeredgecolor="black",
                   markersize=8, linewidth=0,
                   label=label)
        )
    # And a phase-marker key so the reader knows ★ = decode, model-marker = prefill.
    legend_handles.append(
        Line2D([0], [0], marker="*", color="none",
               markerfacecolor="lightgray", markeredgecolor="black",
               markersize=12, linewidth=0, label="(★ = decode point)")
    )

    ax.set_xscale("log")
    ax.set_yscale("log")
    ax.set_xlabel("Arithmetic intensity (FLOPs / byte)")
    ax.set_ylabel("Achieved throughput (TFLOPs/s)")
    ax.set_title("Attention roofline — prefill vs decode  (GPU L40S, BF16)")
    ax.grid(True, alpha=0.3, which="both")
    ax.legend(handles=legend_handles, loc="lower right",
              fontsize=8, framealpha=0.95, ncol=2)

    fig.tight_layout()
    fig.savefig(out_path, bbox_inches="tight", dpi=140)
    plt.close(fig)


def fig_decode_latency_summary(summary_rows, out_path):
    """Single bar chart: median per-token decode latency, one bar per model.

    Decode at attention-layer scope is bandwidth-bound on weights + KV cache,
    so this chart is where MQA/GQA's architectural KV reduction and weight-
    storage quantization (NF4, INT8_wo) actually pay off — unlike prefill,
    where neither of those wins materializes.
    """
    if not summary_rows:
        return

    # One representative cell per model — prefer cuda+bf16 (canonical), else
    # whatever is present. With only one bar per model, separate subplots
    # add nothing; collapse to a single panel with a bar per model.
    by_model = {}
    for r in summary_rows:
        m = r["model"]
        if m not in by_model:
            by_model[m] = r
        elif r["device"] == "cuda" and r["precision"] == "bf16":
            by_model[m] = r

    if not by_model:
        return

    # Stable model ordering — match the rest of the deck.
    _MODEL_ORDER = ["llama2_7b_mha", "starcoder_7b_mqa", "mistral_7b_gqa",
                    "llama31_70b_gqa", "deepseek_v2_mla"]
    rows = sorted(
        by_model.values(),
        key=lambda r: _MODEL_ORDER.index(r["model"])
                      if r["model"] in _MODEL_ORDER else 99,
    )

    labels = [_MODEL_DIMS[r["model"]]["label"]
              if r["model"] in _MODEL_DIMS else r["model"]
              for r in rows]
    ys     = [r["avg_per_token_ms"] for r in rows]
    colors = [_VARIANT_COLOR.get(r.get("variant"), "#888") for r in rows]

    fig, ax = plt.subplots(figsize=(8, 5))
    bars = ax.bar(range(len(rows)), ys, color=colors,
                  edgecolor="black", linewidth=0.6, width=0.55)

    # Numeric labels above bars, with per-batch-element tok/s for context.
    for i, (r, val) in enumerate(zip(rows, ys)):
        B = int(r.get("batch", 1))
        per_step_tps = (B * 1000.0) / val if val > 0 else 0
        ax.text(i, val, f"{val:.2f} ms\n({per_step_tps:,.0f} tok/s, B={B})",
                ha="center", va="bottom", fontsize=8)

    s_init = rows[0]["s_init"]
    n_new  = rows[0]["tokens_decoded"]

    ax.set_xticks(range(len(rows)))
    ax.set_xticklabels(labels, fontsize=8)
    ax.set_ylabel("avg per-token decode latency (ms)")
    ax.set_title(f"Decode-phase per-token latency  "
                 f"(GPU L40S, BF16, S_init={s_init}, +{n_new} new tokens)\n"
                 f"Lower is better.")
    ax.grid(True, axis="y", alpha=0.3)
    ax.set_ylim(0, max(ys) * 1.22)

    fig.tight_layout()
    fig.savefig(out_path, bbox_inches="tight", dpi=140)
    plt.close(fig)


def fig_kv_cache_footprint(decode_summary_rows, out_path, num_layers: int = 32):
    """Bar chart: actual per-layer KV-cache memory at the END of each decode
    run, by (model, variant). Pulls from decode summary data, so the chart
    reflects the real S_total = (s_init + max_new_tokens) used at run time.
    """
    if not decode_summary_rows:
        print("[plot] fig_kv_cache_footprint: no decode rows; skipping.")
        return

    # Group rows by (model, variant). For each, pick BF16 if present (canonical
    # reference; weight-only paths agree with it on KV size by construction).
    by_model = {}
    for r in decode_summary_rows:
        if r["device"] != "cuda":
            continue
        key = r["model"]
        if key not in by_model or r["precision"] == "bf16":
            by_model[key] = r
    if not by_model:
        print("[plot] fig_kv_cache_footprint: no GPU decode rows; skipping.")
        return

    rows = sorted(by_model.values(),
                  key=lambda r: {"MHA": 0, "GQA": 1, "MQA": 2}.get(r["variant"], 9))

    fig, ax = plt.subplots(figsize=(9, 5.4))

    labels      = [f"{r['model']}\n({r['variant']})" for r in rows]
    s_total     = [r["kv_cache_seq_len_final"]      for r in rows]
    bytes_layer = [r["kv_cache_bytes_final"]        for r in rows]
    x = range(len(rows))

    bars1 = ax.bar(list(x), [b/1e6 for b in bytes_layer],
                   width=0.55,
                   label="per-layer (this benchmark scope)",
                   color="#7eb6ff", edgecolor="black", linewidth=0.5)

    for bar, val in zip(bars1, [b/1e6 for b in bytes_layer]):
        ax.text(bar.get_x() + bar.get_width()/2, val, f"{val:.2f} MB",
                ha="center", va="bottom", fontsize=8)

    # X-axis tick labels include the actual S_total each row was measured at.
    full_labels = [f"{lbl}\nS={st}" for lbl, st in zip(labels, s_total)]

    ax.set_yscale("log")
    ax.set_xticks(list(x))
    ax.set_xticklabels(full_labels, fontsize=9)
    ax.set_ylabel("KV cache memory (MB, log)")

    # Adaptive title — describe whichever variants are actually present.
    variants_present = sorted({r["variant"] for r in rows},
                              key=lambda v: _VARIANT_ORDER.index(v) if v in _VARIANT_ORDER else 99)
    if len(variants_present) >= 3:
        subtitle = f"({' vs '.join(variants_present)} architectural difference)"
    elif len(variants_present) == 2:
        subtitle = f"({variants_present[0]} vs {variants_present[1]})"
    else:
        subtitle = f"({variants_present[0] if variants_present else 'no variants'})"
    ax.set_title(f"KV cache footprint at end of decode  {subtitle}")
    ax.legend(loc="upper right", fontsize=9)
    ax.grid(True, axis="y", alpha=0.3)

    fig.tight_layout()
    fig.savefig(out_path, bbox_inches="tight", dpi=140)
    plt.close(fig)


# -----------------------------------------------------------------------------
# Summary writer
# -----------------------------------------------------------------------------

def write_summary(real_rows, synth_rows, out_path):
    cells = {}
    for r in real_rows + synth_rows:
        key = (r["model"], r["device"], r["precision"])
        cells.setdefault(key, []).append(r)

    lines = ["# Results summary\n"]
    lines.append(f"- Real data points: **{len(real_rows)}**")
    lines.append(f"- Synthesized FPGA points: **{len(synth_rows)}** (marked as estimates in all figures)\n")
    lines.append("## Cells populated\n")
    lines.append("| Model | Device | Precision | Samples | Placeholder? |")
    lines.append("|-------|--------|-----------|---------|--------------|")
    for key in sorted(cells):
        model, dev, prec = key
        rows = cells[key]
        n = len(rows)
        placeholder = "yes" if rows[0]["_placeholder"] else "—"
        lines.append(f"| {model} | {dev} | {prec} | {n} | {placeholder} |")

    out_path.write_text("\n".join(lines) + "\n")


# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------

def _parse_cli():
    p = argparse.ArgumentParser()
    p.add_argument("--with-fpga-placeholders", action="store_true",
                   help="Synthesize FPGA placeholder rows (off by default — "
                        "the bars otherwise visually dominate the precision "
                        "comparison without representing real measurements). "
                        "MLA cells are excluded from synthesis even when on.")
    p.add_argument("--share-y", action="store_true",
                   help="Use shared y-axis on multi-panel latency / throughput "
                        "plots. Default is per-panel y because one slow model "
                        "(e.g. DeepSeek MLA) squashes the rest under shared-y.")
    p.add_argument("--bars-batch", type=int, default=PRECISION_BARS_BATCH)
    p.add_argument("--bars-seq",   type=int, default=PRECISION_BARS_SEQ)
    return p.parse_args()


def main():
    args = _parse_cli()

    real = load_all_results()
    if not real:
        print(f"No results found under {RESULTS}/")
        return

    if args.with_fpga_placeholders:
        synth = synthesize_fpga_rows(real)
        print(f"Synthesized {len(synth)} FPGA placeholder rows "
              f"(MLA models excluded per methodology).")
    else:
        synth = []
        print("FPGA placeholders disabled "
              "(pass --with-fpga-placeholders to enable).")

    all_rows = real + synth

    print(f"Loaded {len(real)} real samples from "
          f"{len({r['_source'] for r in real})} files.")
    print(f"Writing figures to {PLOTS}/")

    fig_latency_vs_seq(all_rows, PLOTS / "latency_vs_seq.png",
                       share_y=args.share_y)
    fig_throughput_vs_batch(all_rows, PLOTS / "throughput_vs_batch.png",
                            share_y=args.share_y)
    fig_roofline(all_rows, PLOTS / "roofline.png")
    fig_roofline_per_cell(all_rows, PLOTS / "roofline_per_cell")
    fig_precision_bars(all_rows, PLOTS / "precision_bars.png",
                       batch=args.bars_batch, seq_len=args.bars_seq)
    # Cross-model bars at fixed precision — the chart for the model-axis
    # story (independent of the precision-axis story in precision_bars).
    fig_model_comparison_bars(all_rows, PLOTS / "model_comparison_bars_bf16.png",
                              batch=args.bars_batch, seq_len=args.bars_seq,
                              precision="bf16", device="cuda")
    # Same chart at the headline INT8 cell — int8_wo since that's what's
    # in the data per the user's choice (W8A16 storage, BF16 compute).
    fig_model_comparison_bars(all_rows, PLOTS / "model_comparison_bars_int8wo.png",
                              batch=args.bars_batch, seq_len=args.bars_seq,
                              precision="int8_wo", device="cuda")

    # New figures driven by per-row metric fields added to JSONL output.
    fig_utilization_per_cell(all_rows, PLOTS / "utilization_per_cell.png",
                             batch=args.bars_batch, seq_len=args.bars_seq)
    fig_phase_decomposition(all_rows, PLOTS / "phase_decomposition.png",
                            batch=args.bars_batch, seq_len=args.bars_seq)
    # Static analytical plot — no runs needed.
    fig_mla_decode_kv_traffic(PLOTS / "mla_decode_kv_traffic.png")

    # Decode-phase plots, only if any *_decode.jsonl files exist.
    # Decode is now measured end-to-end (one window per cell); per-token
    # traces no longer exist in the JSONL, so neither does the latency-vs-
    # cache figure that used them.
    decode_summary = load_all_decode_results()
    if decode_summary:
        # Architecture-focused plots:
        fig_decode_variant_latency_bf16(decode_summary,
                                        PLOTS / "decode_variant_latency_bf16.png")
        fig_decode_kv_cache_by_variant(decode_summary,
                                       PLOTS / "decode_kv_cache_by_variant.png")
        fig_decode_roofline(decode_summary,
                            PLOTS / "decode_roofline.png")
        # Combined prefill+decode roofline — uses BOTH datasets.
        fig_combined_prefill_decode_roofline(real, decode_summary,
                                             PLOTS / "roofline_prefill_decode.png")
        # End-to-end workload roofline: one circle per variant, prefill +
        # decode combined into a single AI/throughput coordinate.
        fig_workload_roofline(real, decode_summary,
                              PLOTS / "roofline_workload.png")
        # Detailed plots (kept for backup / Q&A):
        fig_decode_latency_summary(decode_summary, PLOTS / "decode_latency_summary.png")
        fig_kv_cache_footprint(decode_summary, PLOTS / "kv_cache_footprint.png")
        print(f"Decode results found: {len(decode_summary)} cells.")
    else:
        print("No *_decode.jsonl files yet — decode plots skipped. "
              "Run scripts/decode_bench_all.sh first.")

    write_summary(real, synth, PLOTS / "summary.md")

    print("Done. Open plots/ to view.")


if __name__ == "__main__":
    main()