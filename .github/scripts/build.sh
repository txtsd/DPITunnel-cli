#!/bin/ash
set -x

# General updates
apk update
apk add cmake openssl openssl-dev openssl-libs-static linux-headers ninja-is-really-ninja alpine-sdk runuser sudo sed libnl3-static libnl3-dev

# Build static DPITunnel
cmake -S . -B build -DCMAKE_BUILD_TYPE=RELEASE -DSTATIC_BINARY=true -G Ninja
cmake --build build

