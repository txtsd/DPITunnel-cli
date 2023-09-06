#!/bin/ash

# General updates
apk update
apk add cmake openssl openssl-dev openssl-libs-static linux-headers ninja-is-really-ninja alpine-sdk

# Setup build environment
addgroup $(whoami) abuild
mkdir -p /var/cache/distfiles
chmod a+w /var/cache/distfiles
chgrp abuild /var/cache/distfiles
chmod g+w /var/cache/distfiles

# Build static libnl3
abuild-keygen -a -i -b 4096
git clone https://gitlab.alpinelinux.org/alpine/aports.git --depth 1
cd aports/main/libnl3
abuild -r
apk add ~/packages/main/$(abuild -A)/libnl3*

# Build static DPITunnel-cli
cmake -B build -DCMAKE_BUILD_TYPE=RELEASE -DSTATIC_BINARY=true -G Ninja .
cmake --build build

