#!/bin/bash

set -e

echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
apt-get update && apt-get install --assume-yes --no-install-recommends --quiet=2 \
	lsb-release unzip apt-transport-https curl wget gnupg2 ca-certificates locales software-properties-common openssh-client

# Use the latest cmake packages from kitware instead of ubuntu/debian
wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | tee /usr/share/keyrings/kitware-archive-keyring.gpg >/dev/null
echo "deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/kitware.list >/dev/null

packages=$(cat /tmp/dev/packages | sed '/#/d')
echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
apt-get update && ACCEPT_EULA=Y apt-get install --assume-yes --no-install-recommends --quiet=2 $packages
apt-get clean
rm -rf /var/lib/apt/lists/*

# Install gperf
git clone --depth 1 --branch gperftools-2.15 https://github.com/gperftools/gperftools \
	&& cd gperftools \
	&& cmake -DBUILD_TESTING=OFF -B build \
	&& cmake --build build --parallel \
	&& cmake --install build \
	&& cd .. && rm -rf gperftools
