FROM rocm/pytorch:rocm5.4.2_ubuntu20.04_py3.8_pytorch_2.0.0_preview AS base

FROM base AS build-onnxruntime

RUN apt-get update && \
    apt-get install -y ninja-build && \
    pip install cmake==3.26.4

COPY scripts/build-onnxruntime.sh /usr/bin/build-onnxruntime
WORKDIR /build_workspace
RUN git clone https://github.com/microsoft/onnxruntime.git --filter blob:none --no-checkout && \
    cd onnxruntime && git checkout 2fd5e1cc39 && \
    build-onnxruntime build_rocm Release && \
    mkdir -p /build_artifact && \
    cp build_rocm/Release/dist/onnxruntime*.whl /build_artifact/ && \
    rm -rf /build_workspace

FROM base AS converter

COPY --from=build-onnxruntime /build_artifact/onnxruntime*.whl /tmp/build_artifact/
RUN pip install /tmp/build_artifact/onnxruntime*.whl && rm -rf /tmp/build_artifact/
RUN pip install https://repo.radeon.com/rocm/manylinux/rocm-rel-5.4/torch-1.12.1%2Brocm5.4-cp38-cp38-linux_x86_64.whl
RUN pip install transformers==4.29.2 diffusers==0.15.1 accelerate==0.20.3 onnx==1.14.0 numpy==1.22.4

FROM base AS runtime

COPY --from=build-onnxruntime /build_artifact/onnxruntime*.whl /tmp/build_artifact/
RUN pip install /tmp/build_artifact/onnxruntime*.whl && rm -rf /tmp/build_artifact/
RUN pip install torch==2.0.1 --index-url https://download.pytorch.org/whl/rocm5.4.2
RUN pip install transformers==4.29.2 diffusers==0.15.1 accelerate==0.20.3 onnx==1.14.0
