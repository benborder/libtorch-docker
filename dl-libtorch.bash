#!/bin/bash

version=$1; shift
compute_type=$1; shift

# Download libtorch binaries
wget https://download.pytorch.org/libtorch/${compute_type}/libtorch-cxx11-abi-shared-with-deps-${version}%2B${compute_type}.zip -q --show-progress --progress=bar:force:noscroll --directory-prefix /tmp

# Extract to /tmp and cleanup zip
unzip /tmp/libtorch-cxx11-abi-shared-with-deps-${version}+${compute_type}.zip -d /tmp/

# If using cuda, cudnn is already included in base image, so remove it from libtorch directory
if [[ "${compute_type:0:2}" == "cu" ]]; then
    rm /tmp/libtorch/lib/libcudnn*
fi
