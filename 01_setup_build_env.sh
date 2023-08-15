#!/bin/ash

apk update
apk add alpine-sdk doas

doas addgroup $(whoami) abuild
doas mkdir -p /var/cache/distfiles
doas chmod a+w /var/cache/distfiles
doas chgrp abuild /var/cache/distfiles
doas chmod g+w /var/cache/distfiles

