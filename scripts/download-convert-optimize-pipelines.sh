#!/bin/bash

set -ex

PIPELINES_DIR=$(dirname $(realpath $0))/../pipelines
MODEL_CACHING_DIR=~/.cache/huggingface/hub/models--runwayml--stable-diffusion-v1-5

mkdir -p $PIPELINES_DIR

if [[ ! -d $PIPELINES_DIR/torch ]]; then
  f=$(tempfile)_download-sd-1-5.py

  cat > $f << EOF
from diffusers import StableDiffusionPipeline
model_id = "runwayml/stable-diffusion-v1-5"
StableDiffusionPipeline.download(model_id)
EOF
  python $f
  cp -Lr $MODEL_CACHING_DIR/snapshots/$(cat $MODEL_CACHING_DIR/refs/main) $PIPELINES_DIR/torch
  rm $f
fi

if [[ ! -d $PIPELINES_DIR/onnx ]]; then
  f=$(tempfile)_convert_sd_onnx.py
  curl https://raw.githubusercontent.com/huggingface/diffusers/v0.15.1/scripts/convert_stable_diffusion_checkpoint_to_onnx.py > $f
  python $f --model_path $PIPELINES_DIR/torch --output_path  $PIPELINES_DIR/onnx
  rm $f
fi


function optimize_pipeline {
  pipeline_name=$1
  args=${@:2}
  if [[ ! -d $PIPELINES_DIR/$pipeline_name ]]; then
    mkdir -p $PIPELINES_DIR/$pipeline_name
    python -m onnxruntime.transformers.models.stable_diffusion.optimize_pipeline \
      -i $PIPELINES_DIR/onnx \
      -o $PIPELINES_DIR/$pipeline_name $args 2>&1 | \
    tee -i $PIPELINES_DIR/$pipeline_name/optimize.log
  fi
}


optimize_pipeline onnx-fp16 \
  --float16 \
  --disable_attention \
  --disable_group_norm \
  --disable_bias_splitgelu \
  --disable_nhwc_conv

optimize_pipeline onnx-fp16-fmha \
  --float16 \
  --use_multi_head_attention --use_raw_attention_mask \
  --disable_group_norm \
  --disable_bias_splitgelu \
  --disable_nhwc_conv

optimize_pipeline onnx-fp16-fmha-nhwc \
  --float16 \
  --use_multi_head_attention --use_raw_attention_mask \
  --disable_group_norm \
  --disable_bias_splitgelu

optimize_pipeline onnx-fp16-fmha-nhwc-groupnorm \
  --float16 \
  --use_multi_head_attention --use_raw_attention_mask \
  --disable_bias_splitgelu

optimize_pipeline onnx-fp16-fmha-nhwc-groupnorm-biassplitgelu \
  --float16 \
  --use_multi_head_attention --use_raw_attention_mask \

optimize_pipeline onnx-fp16-fmha-nhwc-groupnorm-biassplitgelu-biasadd \
  --float16 \
  --use_multi_head_attention --use_raw_attention_mask \
