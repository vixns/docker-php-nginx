#!/bin/sh
exec 2>&1
mkdir -p /run/haproxy
exec $(which haproxy) -W -f /etc/haproxy/haproxy.cfg