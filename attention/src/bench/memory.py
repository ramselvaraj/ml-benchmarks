"""Memory tracking — peak allocation on GPU, RSS delta on CPU."""
from __future__ import annotations

from contextlib import contextmanager
from dataclasses import dataclass

import torch


@dataclass
class MemoryStats:
    peak_bytes: int
    weights_bytes: int
    kv_cache_bytes: int

    def to_dict(self) -> dict:
        return self.__dict__


def _rss_bytes() -> int:
    try:
        import resource
        return resource.getrusage(resource.RUSAGE_SELF).ru_maxrss * 1024
    except Exception:
        return 0


@contextmanager
def track_peak(device: str):
    """Yield a callable returning peak bytes used inside the block."""
    is_cuda = device.startswith("cuda") and torch.cuda.is_available()
    if is_cuda:
        torch.cuda.reset_peak_memory_stats()
        baseline = 0
    else:
        baseline = _rss_bytes()

    def get_peak() -> int:
        if is_cuda:
            return torch.cuda.max_memory_allocated()
        return max(0, _rss_bytes() - baseline)

    yield get_peak


def kv_cache_bytes(batch: int, seq_len: int, num_kv_heads: int, head_dim: int, dtype: torch.dtype) -> int:
    elem = torch.tensor([], dtype=dtype).element_size()
    return 2 * batch * seq_len * num_kv_heads * head_dim * elem


def weights_bytes(module: torch.nn.Module) -> int:
    """Sum of storage bytes for every parameter, including bitsandbytes
    packed 4/8-bit params. bnb's `Params4bit` reports `numel()` as the
    *packed* element count and `element_size()` as 1 byte, so the naive
    sum is correct — but only because we account for both factors. If a
    future bnb release changes either, this function needs a revisit."""
    total = 0
    for p in module.parameters():
        # For standard tensors: numel * element_size is the storage size.
        # For bnb Params4bit: weight.data is a uint8 packed tensor whose
        # numel is (in*out)/2 and element_size is 1 — so numel*element_size
        # again equals packed bytes. Don't double-count.
        total += p.numel() * p.element_size()
    return total
