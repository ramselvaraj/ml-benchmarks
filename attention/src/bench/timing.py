"""Timing harness with proper warmup and per-platform sync."""
from __future__ import annotations

import statistics
import time
from dataclasses import dataclass
from typing import Callable

import torch


@dataclass
class TimingStats:
    median_ms: float
    p50_ms: float
    p95_ms: float
    p99_ms: float
    mean_ms: float
    stdev_ms: float
    n: int

    def to_dict(self) -> dict:
        return self.__dict__


def time_callable(
    fn: Callable[[], torch.Tensor],
    *,
    device: str,
    warmup: int = 10,
    iters: int = 50,
) -> TimingStats:
    """Run `fn` `warmup + iters` times; return statistics over `iters`."""
    is_cuda = device.startswith("cuda") and torch.cuda.is_available()

    # Warmup
    for _ in range(warmup):
        out = fn()
    if is_cuda:
        torch.cuda.synchronize()

    samples_ms = []
    if is_cuda:
        starts = [torch.cuda.Event(enable_timing=True) for _ in range(iters)]
        ends   = [torch.cuda.Event(enable_timing=True) for _ in range(iters)]
        for i in range(iters):
            starts[i].record()
            out = fn()
            ends[i].record()
        torch.cuda.synchronize()
        samples_ms = [s.elapsed_time(e) for s, e in zip(starts, ends)]
    else:
        for _ in range(iters):
            t0 = time.perf_counter_ns()
            out = fn()
            t1 = time.perf_counter_ns()
            samples_ms.append((t1 - t0) / 1e6)

    samples_ms.sort()
    n = len(samples_ms)
    return TimingStats(
        median_ms=samples_ms[n // 2],
        p50_ms=samples_ms[int(0.50 * (n - 1))],
        p95_ms=samples_ms[int(0.95 * (n - 1))],
        p99_ms=samples_ms[int(0.99 * (n - 1))],
        mean_ms=statistics.fmean(samples_ms),
        stdev_ms=statistics.pstdev(samples_ms),
        n=n,
    )
