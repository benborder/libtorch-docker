FROM ubuntu:22.04 AS download

# Install tools required to download and extract libtorch
RUN apt-get update && \
    apt-get install --assume-yes --no-install-recommends --quiet=2 \
    wget unzip apt-transport-https gnupg2 ca-certificates

COPY dl-libtorch.bash /tmp/dl-libtorch.bash

ARG LIBTORCH_VERSION=2.1.1
ENV LIBTORCH_VERSION=${LIBTORCH_VERSION}

# Download and extract libtorch cpu
RUN /tmp/dl-libtorch.bash ${LIBTORCH_VERSION} cpu

FROM ubuntu:22.04 AS cpu-base

# Copy libtorch to final image
COPY --from=download /tmp/libtorch /usr/local/libtorch
# Make libs discoverable for runtime linking
RUN ldconfig /usr/local/libtorch/lib/ && ldconfig -p | grep /usr/local/libtorch || { echo "Error: libtorch not found in ldconfig paths"; exit 1; }

# Setup the base environment
COPY base /tmp/base
RUN /tmp/base/setup.bash && rm -rf /tmp/base

FROM cpu-base AS cpu-build

# Setup the build environment
COPY build /tmp/build
RUN /tmp/build/setup-build.bash && rm -rf /tmp/build

FROM cpu-build AS cpu-ci

# Setup the ci environment
COPY ci /tmp/ci
RUN /tmp/ci/setup-ci.bash && rm -rf /tmp/ci

# Create a user 'dev'
RUN useradd --create-home --user-group --groups sudo --shell /bin/bash "dev" \
    && mkdir -p /etc/sudoers.d && printf '%s ALL=(ALL:ALL) NOPASSWD: ALL\n' "dev" | tee /etc/sudoers.d/nopasswd;

# Make libs discoverable for runtime linking (For some reason its not carried over from the base image)
RUN ldconfig /usr/local/libtorch/lib/ && ldconfig -p | grep /usr/local/libtorch || { echo "Error: libtorch not found in ldconfig paths"; exit 1; }

# Set the node bin path explicitly to ensure its in the path
ENV PATH="/opt/node/x64/bin:$PATH"
