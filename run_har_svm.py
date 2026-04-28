#!/usr/bin/env python
import subprocess
import sys
import os

os.chdir(r'c:\Users\trent\OneDrive\Documents\GitHub\ml-benchmarks\CPU\har-svm-cpu')

result = subprocess.run([
    sys.executable,
    'har-svm.py'
], timeout=300)

sys.exit(result.returncode)
