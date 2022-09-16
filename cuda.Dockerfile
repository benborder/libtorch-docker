FROM nvidia/cuda:11.6.2-cudnn8-devel-ubuntu20.04 as download

# Install tools required to download and extract libtorch
RUN apt-get update && \
    apt-get install --assume-yes --no-install-recommends --quiet=2 \
    wget unzip apt-transport-https gnupg2 ca-certificates

COPY dl-libtorch.bash /tmp/dl-libtorch.bash

ARG LIBTORCH_VERSION=1.12.1
ENV LIBTORCH_VERSION=${LIBTORCH_VERSION}

# Download and extract libtorch cuda
RUN /tmp/dl-libtorch.bash ${LIBTORCH_VERSION} cu$(echo ${CUDA_VERSION} | sed 's/[^0-9]//g' | cut -c1-3)

FROM nvidia/cuda:11.6.2-cudnn8-devel-ubuntu20.04 as cuda

# Copy libtorch to final image
COPY --from=download /tmp/libtorch /usr/local/libtorch

FROM cuda as cuda-dev

# Setup the dev environment
COPY dev /tmp/dev
RUN /tmp/dev/setup-dev.bash && rm -rf /tmp/dev

# Create a user 'dev'
RUN useradd --create-home --user-group --groups sudo --shell /bin/bash "dev" \
    && mkdir -p /etc/sudoers.d && printf '%s ALL=(ALL:ALL) NOPASSWD: ALL\n' "dev" | tee /etc/sudoers.d/nopasswd;
