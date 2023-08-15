#!/bin/ash

apk add cmake openssl openssl-dev openssl-libs-static linux-headers ninja-is-really-ninja

cmake -B build -DCMAKE_BUILD_TYPE=RELEASE -DSTATIC_BINARY=true -G Ninja .
cmake --build build
