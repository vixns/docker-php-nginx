#!/bin/sh
export PATH=/usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin:/usr/X11R6/bin
onterm() {
  pkill -HUP runsvdir
  exit $?
}
trap onterm TERM INT
runsvdir -P ${SERVICEDIR:-/etc/service} & wait "$!"
