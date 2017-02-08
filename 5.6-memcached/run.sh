#!/bin/sh
exec 1> /proc/1/fd/1
exec 2> /proc/1/fd/2
sed -i -e "s/^mailhub=.*$/mailhub=${SMTP_HOST-opensmtpd}:${SMTP_PORT-25}/" /etc/ssmtp/ssmtp.conf
sed -i -e "s/^root=.*$/root=${EMAIL}/" /etc/ssmtp/ssmtp.conf
exec php-fpm --force-stderr
