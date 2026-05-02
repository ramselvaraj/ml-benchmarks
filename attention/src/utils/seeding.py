"""Deterministic seeding for reproducible inputs and weight init."""
import os
import random

import numpy as np
import torch


def seed_everything(seed: int = 1234, *, strict_cuda: bool = True) -> None:
    """Seed every RNG we touch. When `strict_cuda` is True, also disables
    cuDNN's non-deterministic algorithm selection and TF32 so FP32
    reference runs are bit-reproducible across invocations.

    TF32 is left OFF because the fairness contract wants strict FP32 to
    mean FP32. If you want to benchmark the TF32 regime separately,
    pass `strict_cuda=False` and document it in the JSONL row.
    """
    os.environ["PYTHONHASHSEED"] = str(seed)
    random.seed(seed)
    np.random.seed(seed)
    torch.manual_seed(seed)
    if torch.cuda.is_available():
        torch.cuda.manual_seed_all(seed)
        if strict_cuda:
            torch.backends.cudnn.deterministic = True
            torch.backends.cudnn.benchmark = False
            torch.backends.cuda.matmul.allow_tf32 = False
            torch.backends.cudnn.allow_tf32 = False
