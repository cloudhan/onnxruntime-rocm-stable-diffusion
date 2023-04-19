#!/bin/bash

# assume pwd is onnxruntime repo root

set -ex

./build.sh \
  --build_dir $(pwd)/$1 \
  --config $2 \
  --cmake_generator Ninja \
  --cmake_extra_defines \
      onnxruntime_USE_COMPOSABLE_KERNEL=ON \
  --use_rocm --rocm_home /opt/rocm --rocm_version 5.4.2 \
  --build_wheel \
  --skip_submodule_sync --skip_tests \
  --allow_running_as_root
