#!/bin/bash

set -ex

# during benchmark for multiprocess inference, the numpy blas will oversubscribe
# CPU and will cause severe performance degeneration.
export OPENBLAS_NUM_THREADS=1
export OPENMP_NUM_THREADS=1
export MKL_NUM_THREADS=1

this_dir=$(dirname $0)

python ${this_dir}/benchmark.py \
  --provider=rocm \
  --tuning \
  --tuning_results_load_path ${this_dir}/tuning_results.json \
  --tuning_results_save_path ${this_dir}/tuning_results.json \
  --pipeline=$1 ${@:2} 2>&1 | \
tee -i $1/benchmark.log
