FROM nvidia/cuda:12.8.1-cudnn-devel-ubuntu24.04 AS download

# Install tools required to download and extract libtorch
RUN apt-get update && \
    apt-get install --assume-yes --no-install-recommends --quiet=2 \
    wget unzip apt-transport-https gnupg2 ca-certificates

COPY dl-libtorch.bash /tmp/dl-libtorch.bash

ARG LIBTORCH_VERSION=2.7.1
ENV LIBTORCH_VERSION=${LIBTORCH_VERSION}

# Download and extract libtorch cuda
RUN /tmp/dl-libtorch.bash ${LIBTORCH_VERSION} cu$(echo ${CUDA_VERSION} | sed 's/[^0-9]//g' | cut -c1-3)

FROM nvidia/cuda:12.8.1-cudnn-devel-ubuntu24.04 AS cuda-base

# Copy libtorch to final image
COPY --from=download /tmp/libtorch /usr/local/libtorch
# Make libs discoverable for runtime linking
RUN ldconfig /usr/local/libtorch/lib/ && ldconfig -p | grep /usr/local/libtorch || { echo "Error: libtorch not found in ldconfig paths"; exit 1; }

# Setup the base environment
COPY base /tmp/base
RUN /tmp/base/setup.bash && rm -rf /tmp/base

# Add the EGL settings for nvidia
COPY 10_nvidia.json /usr/share/glvnd/egl_vendor.d/10_nvidia.json

FROM cuda-base AS cuda-build

# Setup the build environment
COPY build /tmp/build
RUN /tmp/build/setup-build.bash && rm -rf /tmp/build

FROM cuda-build AS cuda-dev

# Setup the dev environment
COPY dev /tmp/dev
RUN /tmp/dev/setup-dev.bash && rm -rf /tmp/dev

# nvidia-container-runtime
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility,graphics,display

# Remove the default 'ubuntu' user to free up UID 1000
RUN userdel -r ubuntu || true

# Create a user 'dev'
RUN useradd --create-home --user-group --groups sudo --shell /bin/bash "dev" \
    && mkdir -p /etc/sudoers.d && printf '%s ALL=(ALL:ALL) NOPASSWD: ALL\n' "dev" | tee /etc/sudoers.d/nopasswd;

# Make libs discoverable for runtime linking (For some reason its not carried over from the base image)
RUN ldconfig /usr/local/libtorch/lib/ && ldconfig -p | grep /usr/local/libtorch || { echo "Error: libtorch not found in ldconfig paths"; exit 1; }
