#!/bin/ash
set -x

# General updates
apk update
apk add cmake openssl openssl-dev openssl-libs-static linux-headers ninja-is-really-ninja alpine-sdk runuser sudo sed

# Setup build environment
addgroup $(whoami) abuild
mkdir -p /var/cache/distfiles
chmod a+w /var/cache/distfiles
chgrp abuild /var/cache/distfiles
chmod g+w /var/cache/distfiles
cwd=$(pwd)

# Create user to run abuild
adduser -G abuild -g "Alpine Package Builder" -s /bin/ash -D abuilder
echo "abuilder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Build static libnl3
runuser -u abuilder -- /usr/bin/abuild-keygen -n -a -i -b 4096
cd /home/abuilder
runuser -u abuilder -- git clone https://gitlab.alpinelinux.org/alpine/aports.git --depth 1
cd /home/abuilder/aports/main/libnl3
runuser -u abuilder -- /bin/sed -i "s/subpackages=\"/subpackages=\"\$pkgname-static /" APKBUILD
runuser -u abuilder -- /bin/sed -i "s/--disable-static/--enable-static/" APKBUILD
runuser -u abuilder -- /usr/bin/abuild -r
apk add /home/abuilder/packages/main/$(abuild -A)/libnl3*

# Build static DPITunnel-cli
cd ${cwd}
cmake -B build -DCMAKE_BUILD_TYPE=RELEASE -DSTATIC_BINARY=true -G Ninja .
cmake --build build

