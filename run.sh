#!/bin/sh
exec 2>&1

export PATH=/usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin

ln -sf /proc/$$/fd/1 /tmp/stdout
ln -sf /proc/$$/fd/2 /tmp/stderr

exec runsvdir -P /etc/service
