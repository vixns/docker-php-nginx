#!/bin/sh
exec 2>&1
if [ ! -e "/etc/proxysql/proxysql.cnf" ]; then
  touch down
  sv down .
  exit 0
fi
mkdir -p /var/lib/proxysql
exec proxysql -c /etc/proxysql/proxysql.cnf -D /var/lib/proxysql -f -e