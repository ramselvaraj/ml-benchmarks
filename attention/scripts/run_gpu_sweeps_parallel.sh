#!/bin/bash
# Launch every GPU sweep in parallel, one per visible GPU.
#
# Usage:
#   bash scripts/run_gpu_sweeps_parallel.sh                    # default sweep list
#   bash scripts/run_gpu_sweeps_parallel.sh "bf16 int8 int4"   # override precisions
#
# Requires: CUDA-visible GPUs 0..N-1 (checked with nvidia-smi -L).
# Each sub-run gets its own log under logs/.
# Results land in results/<model>_cuda_<precision>.jsonl as usual.

set -eo pipefail
cd "$(dirname "$0")/.."

# Tier 1 (7B-class) is the default; pass MODELS env to override.
# Tier 2 (production-scale) is added by setting MODELS to include them.
#   MODELS="llama2_7b_mha starcoder_7b_mqa mistral_7b_gqa llama3_70b_gqa starcoderbase_15b_mqa" \
#       bash scripts/run_gpu_sweeps_parallel.sh
MODELS=(${MODELS:-llama2_7b_mha})
PRECISIONS=(${1:-bf16 int8_wo})   # default 4 precisions × 3 models = 12 runs

# Count visible GPUs. We explicitly unset CUDA_VISIBLE_DEVICES here so
# `nvidia-smi -L` sees all physical GPUs, not just the one our
# conda-activate script pinned.
N_GPUS=$(env -u CUDA_VISIBLE_DEVICES nvidia-smi -L | wc -l)
if [[ $N_GPUS -lt 1 ]]; then
    echo "No GPUs visible. Abort."
    exit 1
fi
echo "Detected $N_GPUS GPUs."

mkdir -p logs

# Build the flat list of (model, precision) sweeps
SWEEPS=()
for model in "${MODELS[@]}"; do
    for prec in "${PRECISIONS[@]}"; do
        SWEEPS+=("$model $prec")
    done
done
echo "Total sweeps to run: ${#SWEEPS[@]}"

# Launch up to N_GPUS in parallel, wait, launch the next wave.
pids=()
gpus_in_use=()
for i in "${!SWEEPS[@]}"; do
    read -r model precision <<< "${SWEEPS[$i]}"
    gpu=$(( i % N_GPUS ))
    log="logs/${model}_cuda_${precision}.log"

    printf "[%s] launching  %-20s  %-14s  on GPU %d  (log: %s)\n" \
        "$(date +%H:%M:%S)" "$model" "$precision" "$gpu" "$log"

    CUDA_VISIBLE_DEVICES=$gpu CUDA_DEVICE_ORDER=PCI_BUS_ID \
        python scripts/run_bench.py \
            --config "configs/${model}.yaml" \
            --device cuda --precision "$precision" \
        > "$log" 2>&1 &

    pids+=($!)
    gpus_in_use+=($gpu)

    # If we've filled all GPUs, block until they clear before the next wave.
    if (( (i + 1) % N_GPUS == 0 )) && (( i + 1 < ${#SWEEPS[@]} )); then
        echo "[$(date +%H:%M:%S)] wave full, waiting for ${#pids[@]} jobs..."
        wait "${pids[@]}"
        pids=()
        gpus_in_use=()
    fi
done

echo "[$(date +%H:%M:%S)] waiting for final wave (${#pids[@]} jobs)..."
wait "${pids[@]}"

echo
echo "[$(date +%H:%M:%S)] All sweeps complete."
echo "Results: results/"
echo "Logs:    logs/"
echo
echo "Quick check for failures:"
grep -L "Results written" logs/*.log 2>/dev/null | sed 's/^/  FAILED: /' || true
echo "done."
