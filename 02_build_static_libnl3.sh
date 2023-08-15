#!/bin/ash

abuild-keygen -a -i -b 4096

git clone https://gitlab.alpinelinux.org/alpine/aports.git --depth 1
cd aports/main/libnl3
abuild -r
apk add ~/packages/main/$(abuild -A)/libnl3*
