#!/bin/ash

apk update
apk add alpine-sdk

addgroup $(whoami) abuild
mkdir -p /var/cache/distfiles
chmod a+w /var/cache/distfiles
chgrp abuild /var/cache/distfiles
chmod g+w /var/cache/distfiles

