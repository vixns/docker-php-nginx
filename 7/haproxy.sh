#!/bin/sh
exec 2>&1
if [ ! -e "/etc/haproxy/haproxy.cfg" ]; then
  touch down
  sv stop . > /dev/null
  exit 0
fi
mkdir -p /run/haproxy
exec $(which haproxy) -W -f /etc/haproxy/haproxy.cfg