#!/bin/bash
# Run decode-path benchmark across all (model, device, precision) cells.
#
# GPU sweeps run in parallel (one per visible GPU), 9 cells total.
# CPU sweeps run sequentially under numactl, 6 cells.
#
# Usage:
#   bash scripts/decode_bench_all.sh
#   bash scripts/decode_bench_all.sh --s-init 2048 --max-new-tokens 128

set -eo pipefail
cd "$(dirname "$0")/.."

# Decode hyperparameters — pass --s-init / --max-new-tokens to override.
S_INIT=${S_INIT:-1024}
MAX_NEW=${MAX_NEW:-256}
EXTRA_ARGS="$@"

# Tier 1 (7B-class) by default; override with MODELS env to add tier 2.
#   MODELS="llama2_7b_mha starcoder_7b_mqa mistral_7b_gqa llama3_70b_gqa" \
#       bash scripts/decode_bench_all.sh
MODELS=(${MODELS:-llama2_7b_mha starcoder_7b_mqa mistral_7b_gqa})
GPU_PRECISIONS=(bf16 int8 int4)
CPU_PRECISIONS=(bf16 int8)

mkdir -p logs

# ---- GPU sweeps in parallel (one per GPU) ----
N_GPUS=$(env -u CUDA_VISIBLE_DEVICES nvidia-smi -L | wc -l)
echo "GPU sweeps: $((${#MODELS[@]} * ${#GPU_PRECISIONS[@]})) cells across $N_GPUS GPUs."

pids=()
i=0
for model in "${MODELS[@]}"; do
    for prec in "${GPU_PRECISIONS[@]}"; do
        gpu=$(( i % N_GPUS ))
        log="logs/${model}_cuda_${prec}_decode.log"
        echo "[$(date +%H:%M:%S)] GPU $gpu  $model / $prec  -> $log"
        CUDA_VISIBLE_DEVICES=$gpu CUDA_DEVICE_ORDER=PCI_BUS_ID \
            python scripts/decode_bench.py \
                --config "configs/${model}.yaml" \
                --device cuda --precision "$prec" \
                --s-init "$S_INIT" --max-new-tokens "$MAX_NEW" \
                $EXTRA_ARGS \
                > "$log" 2>&1 &
        pids+=($!)
        i=$((i + 1))
        if (( i % N_GPUS == 0 )); then
            wait "${pids[@]}"
            pids=()
        fi
    done
done
wait "${pids[@]}"

# ---- CPU sweeps sequential under numactl ----
echo "CPU sweeps: $((${#MODELS[@]} * ${#CPU_PRECISIONS[@]})) cells, sequential (NUMA pinned)."
for model in "${MODELS[@]}"; do
    for prec in "${CPU_PRECISIONS[@]}"; do
        log="logs/${model}_cpu_${prec}_decode.log"
        echo "[$(date +%H:%M:%S)] CPU $model / $prec  -> $log"
        OMP_NUM_THREADS=32 numactl --cpunodebind=0 --membind=0 \
            python scripts/decode_bench.py \
                --config "configs/${model}.yaml" \
                --device cpu --precision "$prec" \
                --s-init "$S_INIT" --max-new-tokens "$MAX_NEW" \
                $EXTRA_ARGS \
                > "$log" 2>&1
    done
done

echo
echo "Decode sweeps complete. Results: results/*_decode.jsonl"
echo "Logs: logs/*_decode.log"
