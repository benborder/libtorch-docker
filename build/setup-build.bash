#!/bin/bash

set -e

echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
apt-get update && apt-get install --assume-yes --no-install-recommends --quiet=2 \
	lsb-release apt-transport-https curl wget gnupg2 ca-certificates locales software-properties-common openssh-client

packages=$(cat /tmp/build/packages | sed '/#/d')
echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
apt-get update && ACCEPT_EULA=Y apt-get install --assume-yes --no-install-recommends --quiet=2 $packages
apt-get clean
rm -rf /var/lib/apt/lists/*

# Install protobuf from source as 3.12 is provided in ubuntu 22.04 but libtorch currently requires 3.13
git clone --depth 1 --branch v3.13.0.1 https://github.com/protocolbuffers/protobuf.git \
	&& cd protobuf/cmake \
	&& cmake -Dprotobuf_BUILD_TESTS=OFF -B build \
	&& cmake --build build --parallel \
	&& cmake --install build \
	&& cd ../.. && rm -rf protobuf