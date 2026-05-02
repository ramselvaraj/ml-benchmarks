from .base import AttentionModule, AttentionConfig
from .llama_mha import LlamaMHA
from .starcoder_mqa import StarCoderMQA
from .mistral_gqa import MistralGQA
from .deepseek_mla import DeepseekMLA

# Final lineup — 3 tier-1 (7B variant comparison) + 2 tier-2 (large-model SOTA).
# See METHODOLOGY.md "Attention variants and base models" for rationale.
REGISTRY = {
    # Tier 1 — 7B-class architectural variants (MHA / MQA / GQA).
    "llama2_7b_mha":    LlamaMHA,
    "starcoder_7b_mqa": StarCoderMQA,
    "mistral_7b_gqa":   MistralGQA,
    # Tier 2 — production-scale SOTA face-off (GQA vs MLA).
    "llama31_70b_gqa":  LlamaMHA,    # Llama wrapper is variant-agnostic.
    "deepseek_v2_mla":  DeepseekMLA,
}

__all__ = ["AttentionModule", "AttentionConfig", "REGISTRY"]
