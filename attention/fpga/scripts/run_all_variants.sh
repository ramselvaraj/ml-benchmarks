#!/bin/bash
# run_all_variants.sh — sweep all three attention variants × two precisions.
#
# This is a convenience driver that:
#   1. Regenerates testvectors for the target variant
#   2. Patches NUM_KV_HEADS in attention_top.h (in-place, via sed)
#   3. Runs HLS synthesis
#   4. Scrapes the report into ../results/<model>_fpga_u280_<prec>.jsonl
#
# Designed to be idempotent — re-run safely, overrides previous outputs.
#
# Usage:
#   bash scripts/run_all_variants.sh                            # all six
#   bash scripts/run_all_variants.sh mha int8                   # one cell
#   bash scripts/run_all_variants.sh starcoder int4             # model alias also works

set -eo pipefail
cd "$(dirname "$0")/.."

# -----------------------------------------------------------------------------
# Variant table — kept in sync with the parent configs/
# -----------------------------------------------------------------------------
#
# cols: variant-tag  num_kv_heads  model-for-jsonl  variant-for-jsonl
#
declare -A VARIANTS=(
    [mha]="32  llama2_7b_mha     MHA"
    [gqa]="8   mistral_7b_gqa    GQA"
    [mqa]="1   starcoder_7b_mqa  MQA"
)

PRECISIONS=(int8 int4)

# Which cells to run (defaults to all)
if [[ $# -ge 2 ]]; then
    TARGETS=("$1:$2")
elif [[ $# -eq 1 ]]; then
    TARGETS=("$1:int8" "$1:int4")
else
    TARGETS=()
    for v in mha gqa mqa; do
        for p in int8 int4; do
            TARGETS+=("$v:$p")
        done
    done
fi

# -----------------------------------------------------------------------------
# Driver loop
# -----------------------------------------------------------------------------

for cell in "${TARGETS[@]}"; do
    variant="${cell%%:*}"
    precision="${cell##*:}"

    # Normalize model-name alias ("starcoder" → "mqa")
    case "$variant" in
        llama*|llama2*|mha)    variant=mha ;;
        mistral*|gqa)          variant=gqa ;;
        starcoder*|mqa)        variant=mqa ;;
    esac

    if [[ -z "${VARIANTS[$variant]:-}" ]]; then
        echo "ERROR: unknown variant '$variant' (use mha|gqa|mqa)" >&2
        exit 1
    fi
    read -r kv_heads model_name variant_tag <<< "${VARIANTS[$variant]}"

    echo
    echo "=============================================================="
    echo "  Variant:   $variant  (NUM_KV_HEADS=$kv_heads, $variant_tag)"
    echo "  Precision: $precision"
    echo "  Target:    ../results/${model_name}_fpga_u280_${precision}.jsonl"
    echo "=============================================================="

    # 1. Patch NUM_KV_HEADS in attention_top.h
    sed -i.bak -E "s|(constexpr int NUM_KV_HEADS\s*=\s*)[0-9]+;|\1${kv_heads};|" \
        src/attention_top.h
    grep "NUM_KV_HEADS" src/attention_top.h | head -1

    # 2. Testvectors for this variant at this precision
    python scripts/dump_testvectors.py \
        --precision "$precision" \
        --num-q-heads 32 \
        --num-kv-heads "$kv_heads"

    # 3. Patch run_synth.tcl to point at the right kernel + testbench
    #    (quick in-place edit; the committed TCL defaults to int8)
    if [[ "$precision" == "int4" ]]; then
        sed -i.bak \
            -e 's|attention_int8_kernel|attention_int4_kernel|g' \
            -e 's|attention_int8\.cpp|attention_int4.cpp|g' \
            -e 's|tb_attention_int8\.cpp|tb_attention_int4.cpp|g' \
            scripts/run_synth.tcl
    else
        # Restore int8 defaults if they were patched last iter
        sed -i.bak \
            -e 's|attention_int4_kernel|attention_int8_kernel|g' \
            -e 's|attention_int4\.cpp|attention_int8.cpp|g' \
            -e 's|tb_attention_int4\.cpp|tb_attention_int8.cpp|g' \
            scripts/run_synth.tcl
    fi

    # 4. Synthesis
    vitis_hls -f scripts/run_synth.tcl

    # 5. Scrape the report into a JSONL row for the plotter
    python scripts/parse_reports.py \
        --model "$model_name" \
        --variant "$variant_tag" \
        --precision "$precision" \
        --csynth reports/csynth.rpt \
        --seq-len 1024 --batch 1 \
        --out "../results/${model_name}_fpga_u280_${precision}.jsonl"
done

# Restore defaults
sed -i.bak -E 's|(constexpr int NUM_KV_HEADS\s*=\s*)[0-9]+;|\132;|' src/attention_top.h
rm -f src/attention_top.h.bak scripts/run_synth.tcl.bak

echo
echo "=============================================================="
echo "  All FPGA sweeps complete."
echo "  Results: ../results/*_fpga_u280_*.jsonl"
echo "=============================================================="
