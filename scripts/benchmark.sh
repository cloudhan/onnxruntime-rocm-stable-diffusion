#!/bin/bash

set -ex

python -m onnxruntime.transformers.models.stable_diffusion.benchmark \
  --provider=rocm \
  --tuning \
  --pipeline=$1 ${@:2} 2>&1 | \
tee -i $1/benchmark.log
