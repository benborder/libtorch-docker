#!/bin/bash

set -e

echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
apt-get update \
	&& apt-get install --assume-yes --no-install-recommends --quiet=2 lsb-release unzip apt-transport-https curl wget gnupg2 ca-certificates locales software-properties-common openssh-client \
	&& apt-get clean \

# Use the latest cmake packages from kitware instead of ubuntu/debian
wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | apt-key add -
apt-add-repository "deb https://apt.kitware.com/ubuntu/ $(lsb_release -cs) main"

packages=$(cat /tmp/dev/packages | sed '/#/d')
echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
apt-get update && ACCEPT_EULA=Y apt-get install --assume-yes --no-install-recommends --quiet=2 $packages
apt-get clean
rm -rf /var/lib/apt/lists/*

# Install gperf
git clone https://github.com/gperftools/gperftools \
	&& cd gperftools && mkdir build && cd build \
	&& cmake .. && make && make install \
	&& cd ../.. && rm -rf gperftools
