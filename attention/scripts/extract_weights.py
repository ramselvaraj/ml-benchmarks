"""One-time: download a HF checkpoint, extract a single attention layer,
save it to a small `.safetensors` file.

**Smart shard download** — instead of downloading the entire checkpoint
(which is 470 GB for DeepSeek-V2), we read `model.safetensors.index.json`,
identify which shards contain layer-N's attention tensors, and download
only those. Saves ~99% of the bandwidth and disk for large models.

For non-sharded checkpoints we fall back to `model.safetensors` directly.

After downloading we cross-check the HF model's config against the YAML —
if the YAML claims the wrong hidden_size / num_heads / etc., we raise
rather than let it drift silently into a benchmark run.

Usage:
    python scripts/extract_weights.py --config configs/llama2_7b_mha.yaml
    python scripts/extract_weights.py --config configs/mistral_7b_gqa.yaml
    python scripts/extract_weights.py --config configs/starcoder_7b_mqa.yaml
    python scripts/extract_weights.py --config configs/deepseek_v2_mla.yaml --trust-remote-code
"""
from __future__ import annotations

import argparse
import os
import sys
from pathlib import Path

import yaml

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))


# Per-architecture mapping: HF key-substring to keep, and a function that
# validates the HF config against the YAML. The key-substring match is a
# cheap filter; the validator is the real correctness check.

def _validate_llama_like(hf_cfg, yaml_cfg):
    checks = {
        "hidden_size":            hf_cfg.hidden_size,
        "num_attention_heads":    hf_cfg.num_attention_heads,
        "num_key_value_heads":    getattr(hf_cfg, "num_key_value_heads", hf_cfg.num_attention_heads),
        "max_position_embeddings": hf_cfg.max_position_embeddings,
    }
    for k, v in checks.items():
        if yaml_cfg.get(k) != v:
            raise RuntimeError(
                f"YAML/HF mismatch on {k}: YAML={yaml_cfg.get(k)} vs HF={v}. "
                f"Fix the YAML or pick a different model."
            )


def _validate_deepseek_v2(hf_cfg, yaml_cfg):
    """DeepSeek-V2's HF config uses different field names for MLA dims;
    the YAML schema uses our internal names."""
    checks = {
        "hidden_size":             hf_cfg.hidden_size,
        "num_attention_heads":     hf_cfg.num_attention_heads,
        # DeepSeek's MLA convention: num_key_value_heads == num_attention_heads
        # (the "compression" lives in the latent dim, not the head count).
        "num_key_value_heads":     getattr(hf_cfg, "num_key_value_heads",
                                           hf_cfg.num_attention_heads),
        "max_position_embeddings": hf_cfg.max_position_embeddings,
        "kv_lora_rank":            hf_cfg.kv_lora_rank,
        "qk_nope_head_dim":        hf_cfg.qk_nope_head_dim,
        "qk_rope_head_dim":        hf_cfg.qk_rope_head_dim,
        "v_head_dim":              hf_cfg.v_head_dim,
    }
    # q_lora_rank can be None on V2-Lite; HF stores it as None too.
    yaml_q_lora = yaml_cfg.get("q_lora_rank")
    hf_q_lora = getattr(hf_cfg, "q_lora_rank", None)
    if yaml_q_lora != hf_q_lora:
        raise RuntimeError(
            f"YAML/HF mismatch on q_lora_rank: YAML={yaml_q_lora} vs HF={hf_q_lora}."
        )
    for k, v in checks.items():
        if yaml_cfg.get(k) != v:
            raise RuntimeError(
                f"YAML/HF mismatch on {k}: YAML={yaml_cfg.get(k)} vs HF={v}. "
                f"Fix the YAML or pick a different model."
            )


def _validate_gpt_bigcode(hf_cfg, yaml_cfg):
    checks = {
        "hidden_size":            hf_cfg.n_embd,
        "num_attention_heads":    hf_cfg.n_head,
        "num_key_value_heads":    1 if getattr(hf_cfg, "multi_query", False) else hf_cfg.n_head,
        "max_position_embeddings": hf_cfg.n_positions,
    }
    if not getattr(hf_cfg, "multi_query", False):
        raise RuntimeError("StarCoder config has multi_query=False; expected MQA.")
    for k, v in checks.items():
        if yaml_cfg.get(k) != v:
            raise RuntimeError(
                f"YAML/HF mismatch on {k}: YAML={yaml_cfg.get(k)} vs HF={v}. "
                f"Fix the YAML or pick a different model."
            )


ARCH_HANDLERS = {
    # model_type (from HF config.model_type) -> (key_substrings, validator)
    "llama": (
        lambda i: [f"model.layers.{i}.self_attn."],
        _validate_llama_like,
    ),
    "mistral": (
        lambda i: [f"model.layers.{i}.self_attn."],
        _validate_llama_like,
    ),
    "gpt_bigcode": (
        # gpt_bigcode's position embedding table `transformer.wpe.weight`
        # is shared across layers, so we pull it alongside the layer's
        # attn block.
        lambda i: [f"transformer.h.{i}.attn.", "transformer.wpe.weight"],
        _validate_gpt_bigcode,
    ),
    "deepseek_v2": (
        # DeepSeek-V2 attention lives at model.layers.{i}.self_attn.* and
        # has no shared positional table (RoPE is computed on the fly).
        lambda i: [f"model.layers.{i}.self_attn."],
        _validate_deepseek_v2,
    ),
    "deepseek_v3": (
        # V3 uses the same MLA attention layout as V2.
        lambda i: [f"model.layers.{i}.self_attn."],
        _validate_deepseek_v2,
    ),
}


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--config", required=True)
    p.add_argument("--cache-dir", default=os.environ.get("HF_HOME"))
    # Some HF repos (DeepSeek-V2/V3, others with custom modeling code) ship
    # a Python file that gets executed at load time. HF's loader requires
    # explicit opt-in via trust_remote_code=True. Pass --trust-remote-code
    # for those models. Default off (safer) — the user has to acknowledge
    # they trust the source repo.
    p.add_argument("--trust-remote-code", action="store_true",
                   help="Allow execution of custom model code from the HF "
                        "repo (required for DeepSeek-V2/V3 and similar).")
    p.add_argument("--dry-run-shards", action="store_true",
                   help="Download only the safetensors index, print which "
                        "shards and tensor keys would be fetched, then exit. "
                        "Use this to sanity-check before committing to a "
                        "multi-GB download.")
    args = p.parse_args()

    with open(args.config) as f:
        yaml_cfg = yaml.safe_load(f)
    if yaml_cfg.get("deprecated"):
        raise SystemExit(
            f"{args.config} is marked deprecated; "
            f"use {yaml_cfg.get('replaced_by', '<none>')} instead."
        )

    layer_idx = yaml_cfg["layer_index"]
    repo = yaml_cfg["hf_repo"]
    out_path = ROOT / yaml_cfg["weights_path"]
    out_path.parent.mkdir(parents=True, exist_ok=True)

    print(f"[extract] {repo}  layer={layer_idx}  -> {out_path}")

    import json
    from transformers import AutoConfig
    from huggingface_hub import hf_hub_download
    from huggingface_hub.utils import EntryNotFoundError
    from safetensors import safe_open
    from safetensors.torch import save_file

    if args.trust_remote_code:
        print(f"[extract] WARNING: trust_remote_code=True — custom model code "
              f"from {repo} will be executed.")

    # ---- 1. Download config.json (small) and validate against YAML ----------
    hf_cfg = AutoConfig.from_pretrained(
        repo, cache_dir=args.cache_dir, trust_remote_code=args.trust_remote_code
    )
    handler = ARCH_HANDLERS.get(hf_cfg.model_type)
    if handler is None:
        raise RuntimeError(
            f"No extractor for model_type={hf_cfg.model_type!r}. "
            f"Add one to ARCH_HANDLERS."
        )
    key_substrings_fn, validator = handler
    validator(hf_cfg, yaml_cfg)
    print(f"[extract] HF config validated against {args.config}")

    keep_substrings = key_substrings_fn(layer_idx)

    # ---- 2. Find which shards contain the tensors we want ------------------
    # Try the sharded layout first (model.safetensors.index.json). If the
    # repo isn't sharded, fall back to a single model.safetensors file.
    needed_shards: dict[str, list[str]] = {}    # {shard_filename: [tensor_keys]}

    try:
        index_path = hf_hub_download(
            repo, "model.safetensors.index.json",
            cache_dir=args.cache_dir,
        )
        with open(index_path) as f:
            index = json.load(f)
        weight_map: dict[str, str] = index["weight_map"]
        for k, shard in weight_map.items():
            if any(s in k for s in keep_substrings):
                needed_shards.setdefault(shard, []).append(k)
        if not needed_shards:
            raise RuntimeError(
                f"No tensors matched substrings {keep_substrings} in the "
                f"index of {repo}. Check the architecture handler."
            )
        total_shards = len(set(weight_map.values()))
        print(f"[extract] sharded checkpoint: {total_shards} shards total, "
              f"need {len(needed_shards)} for layer {layer_idx}")
        for shard, keys in sorted(needed_shards.items()):
            print(f"[extract]   {shard}: {len(keys)} tensor(s)")
            for k in sorted(keys):
                print(f"[extract]       {k}")
    except EntryNotFoundError:
        # Single-file checkpoint — download model.safetensors directly.
        print(f"[extract] non-sharded checkpoint, downloading single file")
        needed_shards = {"model.safetensors": []}   # keys filled in after open

    if args.dry_run_shards:
        print(f"[extract] --dry-run-shards: would download "
              f"{len(needed_shards)} shard(s); skipping actual download. exit.")
        return

    # ---- 3. Download only the needed shards (uses cached files if present) -
    shard_paths: dict[str, str] = {}
    for shard in needed_shards:
        print(f"[extract] downloading {shard}")
        shard_paths[shard] = hf_hub_download(
            repo, shard, cache_dir=args.cache_dir,
        )

    # ---- 4. Load the specific tensors we want from each shard --------------
    sd = {}
    for shard, keys in needed_shards.items():
        with safe_open(shard_paths[shard], framework="pt") as f:
            # If we don't have a key list yet (single-file fallback), scan now.
            if not keys:
                keys = [k for k in f.keys() if any(s in k for s in keep_substrings)]
            for k in keys:
                sd[k] = f.get_tensor(k)
    if not sd:
        raise RuntimeError(
            f"No matching attention keys in {repo}. "
            f"Substrings tried: {keep_substrings}"
        )

    save_file(sd, str(out_path))
    mb = sum(t.numel() * t.element_size() for t in sd.values()) / 1e6
    print(f"[extract] saved {len(sd)} tensors, {mb:.1f} MB -> {out_path}")


if __name__ == "__main__":
    main()
