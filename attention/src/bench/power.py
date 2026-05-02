"""Energy / power measurement for benchmark cells.

Two paths, both wrapped in a uniform `PowerSampler` context manager:

- **GPU (NVML)** — background thread polls `nvmlDeviceGetPowerUsage` at
  100ms intervals during the timed window. Mean of samples = avg_power
  (W); trapezoidal integration over time = energy_total (J). Granularity
  is bounded by NVML's internal sampling (~50ms on Ada).

- **CPU (RAPL)** — read `/sys/class/powercap/intel-rapl:0/energy_uj`
  before and after the window; subtract; convert microjoules → joules.
  Mean power = energy / wall_seconds. Single Linux `read()` call per
  endpoint, no background thread needed. Works on AMD Zen with RAPL
  support (the kernel exposes Zen counters under the same intel-rapl
  hierarchy as Intel parts).

Both paths degrade gracefully:
- If NVML isn't installed (no `pynvml`) or the device isn't visible, the
  GPU path returns (None, None) and prints a one-line warning.
- If RAPL sysfs isn't readable (no permission, or the platform doesn't
  expose it), the CPU path does the same.

Caller usage (mirrors track_peak's idiom):

    from src.bench.power import PowerSampler
    with PowerSampler(device="cuda") as sampler:
        ... timed work ...
    avg_power_w, energy_total_j = sampler.result()
"""
from __future__ import annotations

import os
import sys
import threading
import time
from pathlib import Path
from typing import Optional

# ---------------------------------------------------------------------------
# Common
# ---------------------------------------------------------------------------

# RAPL sysfs base — covers Intel and AMD Zen on modern kernels (≥ 5.x).
# We read the "package" energy counter (intel-rapl:0) which sums all cores,
# uncore, and integrated graphics on the first socket.
_RAPL_PATH = "/sys/class/powercap/intel-rapl:0/energy_uj"


class PowerSampler:
    """Context manager that measures energy + average power for a window.

    Args:
        device: "cuda" / "cuda:N" → NVML on that device.
                "cpu"             → RAPL on package 0 (assumes numactl
                                    pin to socket 0 — see METHODOLOGY).
                Anything else     → no-op sampler (returns (None, None)).
        sample_interval_ms: GPU only. Lower = more samples = better
                            integration accuracy, more overhead. 100ms
                            is the sweet spot — well under typical
                            attention-call latencies, and NVML's
                            internal cache is ~50ms anyway.

    On exit, `result()` returns (avg_power_w, energy_total_j) or
    (None, None) if the platform path failed to initialize.
    """

    def __init__(self, device: str = "cpu", sample_interval_ms: int = 100):
        self.device = device
        self.sample_interval_s = sample_interval_ms / 1000.0
        self._impl: Optional["_BasePowerImpl"] = None

        if device.startswith("cuda"):
            self._impl = _NvmlPowerImpl(device, self.sample_interval_s)
        elif device == "cpu":
            self._impl = _RaplPowerImpl()
        else:
            # Unknown device (e.g. fpga_u280) — no-op sampler.
            self._impl = _NoopPowerImpl()

    def __enter__(self) -> "PowerSampler":
        if self._impl is not None:
            self._impl.start()
        return self

    def __exit__(self, exc_type, exc, tb) -> None:
        if self._impl is not None:
            self._impl.stop()

    def result(self) -> tuple[Optional[float], Optional[float]]:
        if self._impl is None:
            return (None, None)
        return self._impl.result()


# ---------------------------------------------------------------------------
# Implementations
# ---------------------------------------------------------------------------

class _BasePowerImpl:
    def start(self) -> None: ...
    def stop(self) -> None: ...
    def result(self) -> tuple[Optional[float], Optional[float]]: ...


class _NoopPowerImpl(_BasePowerImpl):
    def result(self) -> tuple[Optional[float], Optional[float]]:
        return (None, None)


class _NvmlPowerImpl(_BasePowerImpl):
    """NVML-backed sampler. Energy is read from the hardware energy counter
    (`nvmlDeviceGetTotalEnergyConsumption`) when available — exact regardless
    of window length, no polling-rate dependency. Power samples are still
    collected in a background thread for `avg_power` (lets us see power
    variation, which the integrated counter doesn't expose). Both paths
    have fallbacks so the result is sensible even on older drivers/devices.
    """

    def __init__(self, device: str, sample_interval_s: float):
        self.sample_interval_s = sample_interval_s
        self.handle = None
        self._samples_w: list[float] = []
        self._sample_times: list[float] = []
        self._stop_evt: threading.Event = threading.Event()
        self._thread: Optional[threading.Thread] = None
        self._t_start: Optional[float] = None
        self._t_stop: Optional[float] = None
        self._available = False
        # Hardware energy counter state.
        self._energy_supported = False
        self._energy_mj_start: Optional[int] = None
        self._energy_mj_stop: Optional[int] = None

        try:
            import pynvml  # noqa: F401
        except ImportError:
            print("[power] pynvml not installed — GPU power/energy will be "
                  "None. `pip install nvidia-ml-py` to enable.", file=sys.stderr)
            return

        try:
            import pynvml
            pynvml.nvmlInit()
            # Resolve device index: "cuda" or "cuda:N".
            if ":" in device:
                idx = int(device.split(":", 1)[1])
            else:
                # Honor CUDA_VISIBLE_DEVICES if set; otherwise fall back to 0.
                cvd = os.environ.get("CUDA_VISIBLE_DEVICES", "")
                idx = int(cvd.split(",")[0]) if cvd and cvd[0].isdigit() else 0
            self.handle = pynvml.nvmlDeviceGetHandleByIndex(idx)
            self._available = True
            # Feature-detect the energy counter. Available on Volta+ with
            # driver >= 450 / CUDA >= 11. Returns NVMLError_NotSupported on
            # older devices (e.g. Pascal); we then fall back to polling.
            try:
                pynvml.nvmlDeviceGetTotalEnergyConsumption(self.handle)
                self._energy_supported = True
            except Exception:
                self._energy_supported = False
        except Exception as e:
            print(f"[power] NVML init failed ({e}); GPU power/energy will be None.",
                  file=sys.stderr)

    def _poll_loop(self) -> None:
        import pynvml
        next_t = time.perf_counter()
        while not self._stop_evt.is_set():
            try:
                # nvmlDeviceGetPowerUsage returns mW; convert to W.
                mw = pynvml.nvmlDeviceGetPowerUsage(self.handle)
                self._samples_w.append(mw / 1000.0)
                self._sample_times.append(time.perf_counter())
            except Exception:
                pass
            next_t += self.sample_interval_s
            wait = next_t - time.perf_counter()
            if wait > 0:
                self._stop_evt.wait(wait)

    def _read_power_w(self) -> Optional[float]:
        try:
            import pynvml
            return pynvml.nvmlDeviceGetPowerUsage(self.handle) / 1000.0
        except Exception:
            return None

    def start(self) -> None:
        if not self._available:
            return
        self._stop_evt.clear()
        self._samples_w.clear()
        self._sample_times.clear()
        self._t_start = time.perf_counter()
        # Inline polled sample at start: guarantees we have at least one
        # known power reading even if the timed window is so short that
        # the background polling thread doesn't get a chance to fire.
        # Combined with the matching read at stop(), trapezoidal
        # integration always has >=2 samples.
        s = self._read_power_w()
        if s is not None:
            self._samples_w.append(s)
            self._sample_times.append(self._t_start)
        # Snapshot the hardware energy counter at window start.
        if self._energy_supported:
            try:
                import pynvml
                self._energy_mj_start = pynvml.nvmlDeviceGetTotalEnergyConsumption(self.handle)
            except Exception:
                self._energy_mj_start = None
        self._thread = threading.Thread(target=self._poll_loop, daemon=True)
        self._thread.start()

    def stop(self) -> None:
        if not self._available or self._thread is None:
            return
        self._stop_evt.set()
        self._thread.join(timeout=2.0)
        self._t_stop = time.perf_counter()
        # Inline polled sample at stop (see start() for rationale).
        s = self._read_power_w()
        if s is not None:
            self._samples_w.append(s)
            self._sample_times.append(self._t_stop)
        # Snapshot the hardware energy counter at window stop.
        if self._energy_supported:
            try:
                import pynvml
                self._energy_mj_stop = pynvml.nvmlDeviceGetTotalEnergyConsumption(self.handle)
            except Exception:
                self._energy_mj_stop = None

    def result(self) -> tuple[Optional[float], Optional[float]]:
        if not self._available:
            return (None, None)
        wall_s = ((self._t_stop - self._t_start)
                  if (self._t_start is not None and self._t_stop is not None)
                  else None)

        # ---- Energy: prefer the hardware counter, but only when it
        # actually ticked during the window. NVML's energy counter
        # updates at ~10 Hz internally, so for sub-100ms windows the
        # delta can be 0 mJ even when the GPU clearly drew power. In
        # that case we fall through to integrating the polled samples
        # (we ensure ≥2 by snapshotting at start and stop in start()/
        # stop()).
        energy_j: Optional[float] = None

        # Try counter first.
        counter_delta_j: Optional[float] = None
        if (self._energy_supported
                and self._energy_mj_start is not None
                and self._energy_mj_stop is not None):
            counter_delta_j = (self._energy_mj_stop - self._energy_mj_start) / 1000.0
            if counter_delta_j > 0:
                energy_j = counter_delta_j
            # else: counter didn't tick during our window — fall through.

        # Fallback 1: trapezoidal integration of polled samples.
        if energy_j is None and len(self._samples_w) >= 2:
            energy_j = 0.0
            for i in range(1, len(self._samples_w)):
                dt = self._sample_times[i] - self._sample_times[i - 1]
                energy_j += 0.5 * (self._samples_w[i] + self._samples_w[i - 1]) * dt

        # Fallback 2: single-sample × wall_time. Worst-case path; only
        # hit when the inline start/stop reads in start()/stop() failed.
        if energy_j is None and len(self._samples_w) == 1 and wall_s is not None:
            energy_j = self._samples_w[0] * wall_s

        # ---- Avg power: prefer polled mean -----------------------------
        # Polled mean shows variation across the window; counter-derived
        # avg flattens that out. Use polled mean when available, fall
        # back to (energy / wall_time) when no samples were collected.
        avg_w: Optional[float] = None
        if self._samples_w:
            avg_w = sum(self._samples_w) / len(self._samples_w)
        elif energy_j is not None and wall_s and wall_s > 0:
            avg_w = energy_j / wall_s

        return (avg_w, energy_j)


class _RaplPowerImpl(_BasePowerImpl):
    """Single-shot RAPL energy reader. No polling needed — the kernel
    counter already integrates power over time."""

    def __init__(self):
        self._available = Path(_RAPL_PATH).exists() and os.access(_RAPL_PATH, os.R_OK)
        if not self._available:
            print(f"[power] {_RAPL_PATH} not readable — CPU power/energy will "
                  f"be None. (Some platforms require root for RAPL access.)",
                  file=sys.stderr)
        self._energy_uj_start: Optional[int] = None
        self._energy_uj_stop: Optional[int] = None
        self._t_start: Optional[float] = None
        self._t_stop: Optional[float] = None
        self._max_uj = self._read_max_range()

    def _read_max_range(self) -> Optional[int]:
        """RAPL counters wrap around at the max_energy_range_uj value.
        Reading it lets us correct for wraparound during the window."""
        try:
            mr = Path(_RAPL_PATH).parent / "max_energy_range_uj"
            return int(mr.read_text().strip())
        except Exception:
            return None

    def _read_uj(self) -> Optional[int]:
        try:
            return int(Path(_RAPL_PATH).read_text().strip())
        except Exception:
            return None

    def start(self) -> None:
        if not self._available:
            return
        self._energy_uj_start = self._read_uj()
        self._t_start = time.perf_counter()

    def stop(self) -> None:
        if not self._available:
            return
        self._t_stop = time.perf_counter()
        self._energy_uj_stop = self._read_uj()

    def result(self) -> tuple[Optional[float], Optional[float]]:
        if not self._available or self._energy_uj_start is None or self._energy_uj_stop is None:
            return (None, None)
        delta_uj = self._energy_uj_stop - self._energy_uj_start
        # Wraparound correction.
        if delta_uj < 0 and self._max_uj is not None:
            delta_uj += self._max_uj
        energy_j = delta_uj / 1e6
        wall_s = (self._t_stop - self._t_start) if self._t_start and self._t_stop else 0.0
        avg_w = (energy_j / wall_s) if wall_s > 0 else None
        return (avg_w, energy_j)