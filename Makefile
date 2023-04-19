.PHONY: *

RT  := onnxruntime-rocm-stable-diffusion-runtime
CVT := onnxruntime-rocm-stable-diffusion-converter

runtime:
	mkdir -p cache
	DOCKER_BUILDKIT=1 docker build . --target runtime -t ${RT}

converter:
	DOCKER_BUILDKIT=1 docker build . --target converter -t ${CVT}

pipelines:
	docker run --rm -v $$(pwd):/host --workdir /host ${CVT} ./scripts/download-convert-optimize-pipelines.sh

benchmark-ort: benchmark-ort-b1 benchmark-ort-b4 benchmark-ort-b8

benchmark-torch: benchmark-torch-b1 benchmark-torch-b1-compile benchmark-torch-b4 benchmark-torch-b4-compile benchmark-torch-b8 benchmark-torch-b8-compile

# ONNXRuntime related
benchmark-ort-b1:
	docker run --rm -v ~/.cache/huggingface:/root/.cache/huggingface -v $$(pwd):/host --device=/dev/kfd --device=/dev/dri --workdir /host ${RT} scripts/benchmark.sh pipelines/onnx-fp16-fmha-nhwc-groupnorm-biassplitgelu-biasadd -b 1

benchmark-ort-b4:
	docker run --rm -v ~/.cache/huggingface:/root/.cache/huggingface -v $$(pwd):/host --device=/dev/kfd --device=/dev/dri --workdir /host ${RT} scripts/benchmark.sh pipelines/onnx-fp16-fmha-nhwc-groupnorm-biassplitgelu-biasadd -b 4

benchmark-ort-b8:
	docker run --rm -v ~/.cache/huggingface:/root/.cache/huggingface -v $$(pwd):/host --device=/dev/kfd --device=/dev/dri --workdir /host ${RT} scripts/benchmark.sh pipelines/onnx-fp16-fmha-nhwc-groupnorm-biassplitgelu-biasadd -b 8

# torch related
benchmark-torch-b1:
	docker run --rm -v ~/.cache/huggingface:/root/.cache/huggingface -v $$(pwd):/host --device=/dev/kfd --device=/dev/dri --workdir /host ${RT} scripts/benchmark.sh pipelines/torch -e torch -b 1

benchmark-torch-b1-compile:
	docker run --rm -v ~/.cache/huggingface:/root/.cache/huggingface -v $$(pwd):/host --device=/dev/kfd --device=/dev/dri --workdir /host ${RT} scripts/benchmark.sh pipelines/torch -e torch -b 1 --enable_torch_compile

benchmark-torch-b4:
	docker run --rm -v ~/.cache/huggingface:/root/.cache/huggingface -v $$(pwd):/host --device=/dev/kfd --device=/dev/dri --workdir /host ${RT} scripts/benchmark.sh pipelines/torch -e torch -b 4

benchmark-torch-b4-compile:
	docker run --rm -v ~/.cache/huggingface:/root/.cache/huggingface -v $$(pwd):/host --device=/dev/kfd --device=/dev/dri --workdir /host ${RT} scripts/benchmark.sh pipelines/torch -e torch -b 4 --enable_torch_compile

benchmark-torch-b8:
	docker run --rm -v ~/.cache/huggingface:/root/.cache/huggingface -v $$(pwd):/host --device=/dev/kfd --device=/dev/dri --workdir /host ${RT} scripts/benchmark.sh pipelines/torch -e torch -b 8

benchmark-torch-b8-compile:
	docker run --rm -v ~/.cache/huggingface:/root/.cache/huggingface -v $$(pwd):/host --device=/dev/kfd --device=/dev/dri --workdir /host ${RT} scripts/benchmark.sh pipelines/torch -e torch -b 8 --enable_torch_compile
