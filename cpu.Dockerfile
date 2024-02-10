FROM ubuntu:22.04 as download

# Install tools required to download and extract libtorch
RUN apt-get update && \
    apt-get install --assume-yes --no-install-recommends --quiet=2 \
    wget unzip apt-transport-https gnupg2 ca-certificates

COPY dl-libtorch.bash /tmp/dl-libtorch.bash

ARG LIBTORCH_VERSION=2.1.1
ENV LIBTORCH_VERSION=${LIBTORCH_VERSION}

# Download and extract libtorch cpu
RUN /tmp/dl-libtorch.bash ${LIBTORCH_VERSION} cpu

FROM ubuntu:22.04 as cpu

# Copy libtorch to final image
COPY --from=download /tmp/libtorch /usr/local/libtorch
# Make libs discoverable for runtime linking
RUN ldconfig /usr/local/libtorch/lib/

# Setup the base environment
COPY base /tmp/base
RUN /tmp/base/setup.bash && rm -rf /tmp/base

FROM cpu as cpu-dev

# Setup the dev environment
COPY dev /tmp/dev
RUN /tmp/dev/setup-dev.bash && rm -rf /tmp/dev

# Create a user 'dev'
RUN useradd --create-home --user-group --groups sudo --shell /bin/bash "dev" \
    && mkdir -p /etc/sudoers.d && printf '%s ALL=(ALL:ALL) NOPASSWD: ALL\n' "dev" | tee /etc/sudoers.d/nopasswd;
