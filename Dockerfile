FROM php:7.4.29-fpm-bullseye

COPY haproxy-run /etc/service/haproxy/run
COPY proxysql-run /etc/service/proxysql/run
COPY nginx-run /etc/service/nginx/run
COPY php-run /etc/service/php-fpm/run
COPY run.sh /run.sh

ENV PROXYSQL_VERSION=2.3.2

RUN set -x \
    \
    && export DEBIAN_FRONTEND=noninteractive \
    && echo "deb http://http.debian.net/debian bullseye-backports contrib non-free main" >> /etc/apt/sources.list \
    && apt update \
    && apt upgrade -y -t bullseye-backports \
    && apt install --no-install-recommends -t bullseye-backports -y \
        haproxy \
        nginx \
        tini \
        runit \
        gnupg \
        procps \
        libfreetype-dev libjpeg62-turbo-dev libxml2-dev libpng-dev libjpeg-dev libwebp-dev \
&& curl -sL -o /tmp/proxysql.deb https://github.com/sysown/proxysql/releases/download/v${PROXYSQL_VERSION}/proxysql_${PROXYSQL_VERSION}-debian10_$(dpkg --print-architecture).deb \
&& dpkg -i /tmp/proxysql.deb \
&& rm /tmp/proxysql.deb \
&& docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp --enable-gd \
&& docker-php-ext-install gd \
&& dpkg --purge libfreetype-dev libjpeg62-turbo-dev libjpeg-dev libpng-dev libxml2-dev libwebp-dev \
&& apt autoremove -y \
&& rm -rf /var/lib/apt/* \
&& chmod +x /etc/service/haproxy/run /etc/service/proxysql/run /etc/service/nginx/run /etc/service/php-fpm/run \
&& rm -f /usr/local/etc/php-fpm.d/* /etc/haproxy/haproxy.cfg \
&& echo "date.timezone=UTC" >> "/usr/local/etc/php/conf.d/timezone.ini" \
&& echo "pdo_mysql.default_socket=/run/mysql.sock" >> "/usr/local/etc/php/conf.d/pdo_mysql.ini" \
&& echo "mysql.default_socket=/run/mysql.sock" >> "/usr/local/etc/php/conf.d/mysql.ini" \
&& echo "mysqli.default_socket=/run/mysql.sock" >> "/usr/local/etc/php/conf.d/mysqli.ini" \
&& echo "zend_extension=opcache.so" >> "/usr/local/etc/php/conf.d/ext-opcache.ini" \
&& echo "opcache.enable_cli=0" >> "/usr/local/etc/php/conf.d/ext-opcache.ini" \
&& echo "opcache.memory_consumption=128" >> "/usr/local/etc/php/conf.d/ext-opcache.ini" \
&& echo "opcache.interned_strings_buffer=8" >> "/usr/local/etc/php/conf.d/ext-opcache.ini" \
&& echo "opcache.max_accelerated_files=4000" >> "/usr/local/etc/php/conf.d/ext-opcache.ini" \
&& echo "opcache.fast_shutdown=1" >> "/usr/local/etc/php/conf.d/ext-opcache.ini" \
&& ln -sf /proc/1/fd/1 /var/log/nginx/access.log \
&& ln -sf /proc/1/fd/2 /var/log/nginx/error.log \
&& chmod +x /run.sh

COPY nginx.conf /etc/nginx/nginx.conf
COPY www.conf /usr/local/etc/php-fpm.d/www.conf
COPY php-fpm.conf /usr/local/etc/php-fpm.conf

ENTRYPOINT ["/usr/bin/tini"]
CMD ["/run.sh"]
