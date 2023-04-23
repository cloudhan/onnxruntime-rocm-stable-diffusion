# Run Stable Diffusion on AMD GPUs with ONNXRuntime ROCm EP

## Disclaimer

I am employed by Microsoft and is working on ONNXRuntime ROCm EP (as of
2023-04-20). The result of this repo is a side effect of my work and is not
endorsed by Microsoft. The code is hereby provided for the ease of
reproducibility of the conversion and optimization of the model pipeline.

THE BENCHMARK RESULTS ARE PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE STABILITY OR
REPRODUCIBILITY OF THE PERFORMANCE NUMBER.

## About

## Steps

```bash
# you might comment out some unneeded intermediate pipelines from
# scripts/download-convert-optimize-pipelines.sh
make converter
make pipelines

make runtime
make benchmark-ort
make benchmark-torch
```

## Results

- Batch size, abbr. as BS
- Latency in seconds
- Memory in MB

### MI250X (1 GCD)

| Optimizations                                                         | Latency (BS=1) | Memory (BS=1) | Latency (BS=8) | Memory (BS=8)
| --------------------------------------------------------------------- | -------------- | ------------- | -------------- | -------------
| Raw FP32 models                                                       | 6.7            | 17319         | 36.4 *         | 33787
| FP16 baseline                                                         | 4.1            | 8945          | 24.0 *         | 34493
| FP16 baseline + FMHA                                                  | 2.6            | 4886          | 15.0           | 10146
| FP16 baseline + FMHA + NhwcConv                                       | 2.4            | 4952          | 14.8           | 9632
| FP16 baseline + FMHA + NhwcConv + GroupNorm                           | 2.3            | 4906          | 13.6           | 9774
| FP16 baseline + FMHA + NhwcConv + GroupNorm + BiasSplitGelu           | 2.2            | 4910          | 12.5           | 9646
| FP16 baseline + FMHA + NhwcConv + GroupNorm + BiasSplitGelu + BiasAdd | 2.2            | 4910          | 12.5           | 9778

**Note**: Results marked as `*` produce suspicious images. It seems to be caused by intermediate numerical error accumulation.

| Engine      | Version         | Cases   | BS | Latency | First run memory | Second run memory
| ----------- | --------------- | ------- | -- | ------- | ---------------- | -----------------
| onnxruntime | dev             | ROCm EP | 1  | 2.2     | 5548             | 4908
| torch       | 1.12.1+rocm5.4  | -       | 1  | 3.4     | 6653             | 4613
| torch       | 2.0.0+rocm5.4.2 | default | 1  | 3.2     | 5977             | 4368
| torch       | 2.0.0+rocm5.4.2 | compile | 1  | 3.0     | 5869             | 4266
| onnxruntime | dev             | ROCm EP | 4  | 6.6     | 5546             | 4906
| torch       | 1.12.1+rocm5.4  | -       | 4  | 10.1    | 19477            | 11325
| torch       | 2.0.0+rocm5.4.2 | default | 4  | 10.5    | 13051            | 7300
| torch       | 2.0.0+rocm5.4.2 | compile | 4  | 9.2     | 12879            | 7190
| onnxruntime | dev             | ROCm EP | 8  | 12.5    | 9778             | 9006
| torch       | 1.12.1+rocm5.4  | -       | 8  | 19.3    | 55851            | 20014
| torch       | 2.0.0+rocm5.4.2 | default | 8  | 20.3    | 23551            | 11930
| torch       | 2.0.0+rocm5.4.2 | compile | 8  | 17.8    | 23303            | 11800

### MI100

| Engine      | Version         | Cases   | BS | Latency | First run memory | Second run memory
| ----------- | --------------- | ------- | -- | ------- | ---------------- | -----------------
| onnxruntime | dev             | ROCm EP | 1  | 2.4     | 5254             | 4614
| torch       | 1.12.1+rocm5.4  | -       | 1  | 3.5     | 5771             | 4672
| torch       | 2.0.0+rocm5.4.2 | default | 1  | 3.5     | 5811             | 4206
| torch       | 2.0.0+rocm5.4.2 | compile | 1  | 3.1     | 5774             | 4168
| onnxruntime | dev             | ROCm EP | 4  | 7.5     | 7290             | 6646
| torch       | 1.12.1+rocm5.4  | -       | 4  | 10.7    | 19334            | 11181
| torch       | 2.0.0+rocm5.4.2 | default | 4  | 11.5    | 12881            | 7151
| torch       | 2.0.0+rocm5.4.2 | compile | 4  | 10.0    | 12740            | 7073
| onnxruntime | dev             | ROCm EP | 8  | 14.4    | 7320             | 6676
| torch       | 1.12.1+rocm5.4  | -       | 8  | 20.2    | 31820            | 19908
| torch       | 2.0.0+rocm5.4.2 | default | 8  | 22.2    | 23415            | 11815
| torch       | 2.0.0+rocm5.4.2 | compile | 8  | 19.3    | 23154            | 11667
