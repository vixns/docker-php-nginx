#!/bin/sh
exec 1> /dev/stdout
exec 2> /dev/stderr
exec /usr/sbin/nginx -g "daemon off;"