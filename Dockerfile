FROM php:8.3.37-fpm-trixie

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
&& wget -nv -O- https://nginx.org/keys/nginx_signing.key | gpg --dearmor -o /usr/share/keyrings/nginx-archive-keyring.gpg \
&& echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] http://nginx.org/packages/debian $(lsb_release -sc) nginx" > /etc/apt/sources.list.d/nginx.list \
&& printf '%s\n' 'Package: nginx' 'Pin: version 1.30.7-1~trixie' 'Pin-Priority: 1001' > /etc/apt/preferences.d/nginx \
&& apt update \
&& apt install --no-install-recommends -y \
    haproxy \
    nginx=1.30.7-1~trixie \
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
&& echo "opcache.enable_cli=0" >> "/usr/local/etc/php/conf.d/ext-opcache.ini" \
&& echo "opcache.memory_consumption=128" >> "/usr/local/etc/php/conf.d/ext-opcache.ini" \
&& echo "opcache.interned_strings_buffer=8" >> "/usr/local/etc/php/conf.d/ext-opcache.ini" \
&& echo "opcache.max_accelerated_files=4000" >> "/usr/local/etc/php/conf.d/ext-opcache.ini" \
&& mkdir -p /var/lib/proxysql /etc/nginx/modules-enabled /var/lib/nginx /var/cache/nginx \
&& rm -f /etc/nginx/conf.d/default.conf \
&& chown -R www-data /etc/service /var/lib/proxysql /etc/nginx /var/lib/nginx /var/log/nginx /var/cache/nginx

COPY nginx.conf /etc/nginx/nginx.conf
COPY www.conf /usr/local/etc/php-fpm.d/www.conf
COPY php-fpm.conf /usr/local/etc/php-fpm.conf

USER www-data
ENTRYPOINT ["/usr/bin/tini"]
CMD ["/run.sh"]
