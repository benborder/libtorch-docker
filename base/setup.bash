#!/bin/bash

set -e

packages=$(cat /tmp/base/packages | sed '/#/d')
echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
apt-get update && ACCEPT_EULA=Y apt-get install --assume-yes --no-install-recommends --quiet=2 $packages
apt-get clean
rm -rf /var/lib/apt/lists/*
