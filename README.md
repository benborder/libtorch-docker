# libtorch-docker

Creates libtorch based docker images for both cpu and cuda

## Building locally

```bash
docker build -f cpu.Dockerfile -t libtorch-docker:cpu-dev .
docker build -f cuda.Dockerfile -t libtorch-docker:cuda-dev .
```
