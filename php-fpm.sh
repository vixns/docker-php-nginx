#!/bin/sh
exec 1> /proc/1/fd/1
exec 2> /proc/1/fd/2
sed -i -e "s/\$PHP_USER/${PHP_USER}/" /usr/local/etc/php-fpm.d/*
exec php-fpm --force-stderr
