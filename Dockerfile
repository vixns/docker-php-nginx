FROM php:8.4.23-fpm-trixie

COPY haproxy-run /etc/service/haproxy/run
COPY proxysql-run /etc/service/proxysql/run
COPY nginx-run /etc/service/nginx/run
COPY php-run /etc/service/php-fpm/run
COPY run.sh /run.sh

ENV PROXYSQL_VERSION=3.0

RUN set -x \
&& export DEBIAN_FRONTEND=noninteractive \
&& apt update \
&& apt-get install -y --no-install-recommends lsb-release wget apt-transport-https ca-certificates gnupg \
&& wget -nv -O /etc/apt/trusted.gpg.d/proxysql-3.0.x-keyring.gpg 'https://repo.proxysql.com/ProxySQL/proxysql-3.0.x/repo_pub_key.gpg' \
&& echo deb https://repo.proxysql.com/ProxySQL/proxysql-${PROXYSQL_VERSION}.x/$(lsb_release -sc)/ ./ | tee /etc/apt/sources.list.d/proxysql.list \
&& apt update \
&& apt install --no-install-recommends -y \
    haproxy \
    nginx \
    runit \
    tini \
    procps \
    proxysql \
    libfreetype-dev libjpeg62-turbo-dev libxml2-dev libpng16-16 libwebp7 libjpeg62-turbo libfreetype6 libpng-dev libjpeg-dev libwebp-dev \
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
&& mkdir -p /var/lib/proxysql \
&& chown -R www-data /etc/service /var/lib/proxysql /etc/nginx /var/lib/nginx /var/log/nginx

COPY nginx.conf /etc/nginx/nginx.conf
COPY www.conf /usr/local/etc/php-fpm.d/www.conf
COPY php-fpm.conf /usr/local/etc/php-fpm.conf

USER www-data
ENTRYPOINT ["/usr/bin/tini"]
CMD ["/run.sh"]
