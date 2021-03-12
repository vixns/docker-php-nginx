#!/bin/sh
exec 2>&1

export PATH=/usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin

ln -sf /dev/stdout /tmp/stdout
ln -sf /dev/stderr /tmp/stderr

if [ -n "$MESOS_SANDBOX" ]
then
	ln -sf ${MESOS_SANDBOX}/stdout /tmp/stdout
	ln -sf ${MESOS_SANDBOX}/stderr /tmp/stderr
fi

exec runsvdir -P /etc/service
