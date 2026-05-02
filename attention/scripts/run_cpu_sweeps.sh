#!/bin/bash
# run_cpu_sweeps.sh — sequential CPU prefill sweeps under numactl.
#
# CPU runs MUST be launched through numactl. Without `--cpunodebind=0
# --membind=0`, cross-socket memory traffic adds 30-50% silent latency
# noise, which makes every measurement unusable for the methodology's
# fairness contract.
#
# Sequential because each run already pegs all 32 cores of one NUMA node
# (`OMP_NUM_THREADS=32`). Parallel runs would fight for L3 and the
# numbers would degrade for both.
#
# Defaults: the 5-model lineup × {bf16, int8}. Override either with env vars.
# Examples:
#   bash scripts/run_cpu_sweeps.sh                        # all 10 cells
#   MODELS="llama2_7b_mha mistral_7b_gqa" bash scripts/run_cpu_sweeps.sh
#   PRECISIONS="bf16" bash scripts/run_cpu_sweeps.sh     # bf16 only
#
# Logs land in logs/<model>_cpu_<precision>.log.
# Results land in results/<model>_cpu_<precision>.jsonl (overwrite by default).

set -eo pipefail
cd "$(dirname "$0")/.."

MODELS=(${MODELS:-llama2_7b_mha})
PRECISIONS=(${PRECISIONS:-bf16 int8})

mkdir -p logs

# numactl sanity-check: bail early if it isn't installed.
if ! command -v numactl >/dev/null 2>&1; then
    echo "ERROR: numactl not found. Install (e.g. \`sudo apt install numactl\`)" >&2
    echo "       and re-run. CPU benchmarks without NUMA pinning are not valid"   >&2
    echo "       per METHODOLOGY.md."                                              >&2
    exit 1
fi

total=$(( ${#MODELS[@]} * ${#PRECISIONS[@]} ))
done_count=0
echo "CPU sweeps: $total cells (${#MODELS[@]} models × ${#PRECISIONS[@]} precisions), sequential under numactl."
echo "Models:     ${MODELS[*]}"
echo "Precisions: ${PRECISIONS[*]}"
echo

for model in "${MODELS[@]}"; do
    for prec in "${PRECISIONS[@]}"; do
        done_count=$((done_count + 1))
        log="logs/${model}_cpu_${prec}.log"
        printf "[%s] (%d/%d) %-22s  %-5s  -> %s\n" \
            "$(date +%H:%M:%S)" "$done_count" "$total" "$model" "$prec" "$log"
        OMP_NUM_THREADS=32 numactl --cpunodebind=0 --membind=0 \
            python scripts/run_bench.py \
                --config "configs/${model}.yaml" \
                --device cpu --precision "$prec" \
                > "$log" 2>&1
    done
done

echo
echo "All CPU sweeps complete."
echo "Results: results/*_cpu_*.jsonl"
echo "Logs:    logs/*_cpu_*.log"
echo
echo "Quick-check for failures:"
grep -L "Results written to" logs/*_cpu_*.log 2>/dev/null \
    | sed 's/^/  FAILED: /' || echo "  (all sweeps wrote results)"
