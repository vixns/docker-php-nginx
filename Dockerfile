FROM php:7.4-fpm

COPY haproxy-run /etc/service/haproxy/run
COPY proxysql-run /etc/service/proxysql/run
COPY nginx-run /etc/service/nginx/run
COPY php-run /etc/service/php-fpm/run
COPY run.sh /run.sh

ENV TINI_VERSION=0.18.0

RUN set -x \
	\
	&& export DEBIAN_FRONTEND=noninteractive \
	&& echo "deb http://http.debian.net/debian buster-backports contrib non-free main" >> /etc/apt/sources.list \
	&& apt-get update \
	&& apt-get dist-upgrade -y -t buster-backports \
	&& apt-get install --no-install-recommends -t buster-backports -y \
		haproxy \
		nginx \
		runit \
                gnupg \
		procps \
	        libfreetype6-dev libjpeg62-turbo-dev libxml2-dev libpng-dev libjpeg-dev \
	\
# install proxysql
&& curl -sL -o /tmp/proxysql_2.0.0-debian9_amd64.deb https://github.com/sysown/proxysql/releases/download/v2.0.6/proxysql_2.0.6-debian9_amd64.deb \
&& dpkg -i /tmp/proxysql_2.0.0-debian9_amd64.deb \
&& rm /tmp/proxysql_2.0.0-debian9_amd64.deb \
&& docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-png-dir=/usr/include/ \
&& docker-php-ext-install gd \
&& dpkg --purge libfreetype6-dev libjpeg62-turbo-dev libjpeg-dev libpng-dev libxml2-dev \
&& apt-get autoremove -y \
&& rm -rf /var/lib/apt/* \
&& chmod +x /etc/service/haproxy/run /etc/service/proxysql/run /etc/service/nginx/run /etc/service/php-fpm/run \
&& rm -f /usr/local/etc/php-fpm.d/* /etc/haproxy/haproxy.cfg \
&& echo "date.timezone=UTC" >> "/usr/local/etc/php/conf.d/timezone.ini" \
&& echo "pdo_mysql.default_socket=/run/mysql.sock" >> "/usr/local/etc/php/conf.d/pdo_mysql.ini" \
&& echo "mysql.default_socket=/run/mysql.sock" >> "/usr/local/etc/php/conf.d/mysql.ini" \
&& echo "mysqli.default_socket=/run/mysql.sock" >> "/usr/local/etc/php/conf.d/mysqli.ini" \
&& echo "zend_extension=opcache.so" >> "/usr/local/etc/php/conf.d/ext-opcache.ini" \
&& echo "opcache.enable_cli=1" >> "/usr/local/etc/php/conf.d/ext-opcache.ini" \
&& echo "opcache.memory_consumption=128" >> "/usr/local/etc/php/conf.d/ext-opcache.ini" \
&& echo "opcache.interned_strings_buffer=8" >> "/usr/local/etc/php/conf.d/ext-opcache.ini" \
&& echo "opcache.max_accelerated_files=4000" >> "/usr/local/etc/php/conf.d/ext-opcache.ini" \
&& echo "opcache.fast_shutdown=1" >> "/usr/local/etc/php/conf.d/ext-opcache.ini" \
&& ln -sf /proc/1/fd/1 /var/log/nginx/access.log \
&& ln -sf /proc/1/fd/2 /var/log/nginx/error.log \
&& curl -s -L -o /tmp/tini_${TINI_VERSION}-amd64.deb https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini_${TINI_VERSION}-amd64.deb \
&& dpkg -i /tmp/tini_${TINI_VERSION}-amd64.deb \
&& rm /tmp/tini_${TINI_VERSION}-amd64.deb \
&& chmod +x /run.sh

COPY nginx.conf /etc/nginx/nginx.conf
COPY www.conf /usr/local/etc/php-fpm.d/www.conf
COPY php-fpm.conf /usr/local/etc/php-fpm.conf

ENTRYPOINT ["tini"]
CMD ["/run.sh"]
