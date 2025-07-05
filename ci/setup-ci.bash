#!/bin/bash

set -e

packages=$(cat /tmp/ci/packages | sed '/#/d')
echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
apt-get update && ACCEPT_EULA=Y apt-get install --assume-yes --no-install-recommends --quiet=2 $packages
apt-get clean
rm -rf /var/lib/apt/lists/*

NODE_VERSION="18"

VER=$(curl https://nodejs.org/download/release/index.json | jq "[.[] | select(.version|test(\"^v${NODE_VERSION}\"))][0].version" -r)
NODEPATH=/opt/node/x64
sudo mkdir -v -m 0777 -p "$NODEPATH"
wget "https://nodejs.org/download/release/latest-v${NODE_VERSION}.x/node-$VER-linux-x64.tar.xz" -O "node-$VER-linux-x64.tar.xz"
sudo tar -Jxf "node-$VER-linux-x64.tar.xz" --strip-components=1 -C "$NODEPATH"
rm "node-$VER-linux-x64.tar.xz"
sudo sed -i 's|PATH="\(.*\)"|PATH="'"$NODEPATH/bin:"'\1"|g' /etc/environment
export PATH="$NODEPATH/bin:$PATH"
