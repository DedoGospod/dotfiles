#!/usr/bin/env bash

set -e
set -o pipefail

echo "--- Detecting System Capabilities ---"
/lib/ld-linux-x86-64.so.2 --help | grep "supported"

echo "--- Downloading CachyOS Repo Helper ---"
WORKDIR=$(mktemp -d)
cd "$WORKDIR"

curl -L https://mirror.cachyos.org/cachyos-repo.tar.xz -o cachyos-repo.tar.xz

echo "--- Extracting and Installing ---"
tar xvf cachyos-repo.tar.xz
cd cachyos-repo

sudo -v
sudo ./cachyos-repo.sh

echo "--- Cleaning up ---"
rm -rf "$WORKDIR"

echo "Done! Please run 'sudo pacman -Syu' to synchronize your new repositories."
