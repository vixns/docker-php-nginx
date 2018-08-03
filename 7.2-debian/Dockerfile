FROM php:7.2-fpm

ENV HAS_HAPROXY= HAS_PROXYSQL= MYSQL_SERVERS= MYSQL_USERS= PROXYSQL_RULES= PROXYSQL_ADMIN_USER=radmin PROXYSQL_ADMIN_PASS=changeradminpass PROXYSQL_STATS_USER=stats PROXYSQl_STATS_PASS=stats PROXYSQL_MONITOR_USER=monitor PROXYSQL_MONITOR_PASS=monitor \
PROXYSQL_VERSION=1.4.9 HAPROXY_VERSION=1.8.13 TINI_VERSION=0.18.0

COPY . /src

RUN \
echo "deb http://http.debian.net/debian stretch-backports contrib non-free main" >> /etc/apt/sources.list && \
apt-get update && apt-get --no-install-recommends -y dist-upgrade && \
apt-get install --no-install-recommends -t stretch-backports -y nginx runit libicu-dev zlib1g-dev libjpeg-dev libpng-dev librsvg2-dev libicu57 imagemagick git libssl-dev xfonts-base xfonts-75dpi libfreetype6-dev procps && \
mkdir -p /usr/local/etc/php-fpm.d && \
docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/lib && docker-php-ext-install sockets intl zip gd && \
  echo "date.timezone=UTC" >> "/usr/local/etc/php/conf.d/timezone.ini" && \
  echo "zend_extension=opcache.so" >> "/usr/local/etc/php/conf.d/ext-opcache.ini" && \
  echo "opcache.enable_cli=1" >> "/usr/local/etc/php/conf.d/ext-opcache.ini" && \
  echo "opcache.memory_consumption=128" >> "/usr/local/etc/php/conf.d/ext-opcache.ini" && \
  echo "opcache.interned_strings_buffer=8" >> "/usr/local/etc/php/conf.d/ext-opcache.ini" && \
  echo "opcache.max_accelerated_files=4000" >> "/usr/local/etc/php/conf.d/ext-opcache.ini" && \
  echo "opcache.fast_shutdown=1" >> "/usr/local/etc/php/conf.d/ext-opcache.ini" && \
  echo "pdo_mysql.default_socket=/run/mysql.sock" >> "/usr/local/etc/php/conf.d/pdo_mysql.ini" && \
  echo "mysql.default_socket=/run/mysql.sock" >> "/usr/local/etc/php/conf.d/mysql.ini" && \
  echo "mysqli.default_socket=/run/mysql.sock" >> "/usr/local/etc/php/conf.d/mysqli.ini" && \
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
ln -sf /proc/1/fd/1 /var/log/nginx/access.log && \
ln -sf /proc/1/fd/2 /var/log/nginx/error.log && \
rm /usr/local/etc/php-fpm.d/*conf && \
apt-get update && apt-get -t stretch-backports -y install haproxy && \
curl -s -L -o /tmp/haproxy-${HAPROXY_VERSION}.tar.gz http://www.haproxy.org/download/1.8/src/haproxy-${HAPROXY_VERSION}.tar.gz && \
cd /tmp && tar zxf haproxy-${HAPROXY_VERSION}.tar.gz && cd haproxy-${HAPROXY_VERSION} && \
make TARGET=linux2628 USE_PCRE=1 USE_OPENSSL=1 USE_ZLIB=1 && \
mv haproxy /usr/sbin/haproxy && cd /tmp && rm -rf haproxy* && \
curl -s -L -o /tmp/proxysql_${PROXYSQL_VERSION}-debian9_amd64.deb https://github.com/sysown/proxysql/releases/download/v1.4.9/proxysql_${PROXYSQL_VERSION}-debian9_amd64.deb && \
dpkg -i /tmp/proxysql_${PROXYSQL_VERSION}-debian9_amd64.deb && \
rm /tmp/proxysql_${PROXYSQL_VERSION}-debian9_amd64.deb && \
curl -s -L -o /tmp/tini_0.18.0-amd64.deb https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini_${TINI_VERSION}-amd64.deb && \
dpkg -i /tmp/tini_${TINI_VERSION}-amd64.deb && \
rm tini_${TINI_VERSION}-amd64.deb && \
dpkg --purge libicu-dev libxml2-dev libfreetype6-dev libgraphviz-dev libglib2.0-dev libtiff5-dev libwmf-dev libcairo2-dev libsodium-dev libgdk-pixbuf2.0-dev libfontconfig1-dev librsvg2-dev && \
apt -y autoremove && \
rm -rf /var/lib/apt/lists/* && \
mkdir -p /etc/service/php-fpm/ && \
mkdir -p /etc/service/nginx/ /etc/service/haproxy/ /etc/service/proxysql/ && \
mv /src/policy.xml /etc/ImageMagick-6/policy.xml && \
mv /src/nginx.conf /etc/nginx/nginx.conf && \
mv /src/nginx-default.conf /etc/nginx/conf.d/default.conf && \
mv /src/php-fpm.conf /usr/local/etc/php-fpm.conf && \
rm -f /usr/local/etc/php-fpm.d/* && \
mv /src/fpm-www.conf /usr/local/etc/php-fpm.d/www.conf && \
mv /src/php-fpm.sh /etc/service/php-fpm/run && \
mv /src/nginx.sh /etc/service/nginx/run && \
mv /src/haproxy.sh /etc/service/haproxy/run && \
mv /src/proxysql.sh /etc/service/proxysql/run && \
mv /src/run.sh /run.sh && \
chmod 755 /run.sh /etc/service/haproxy/run /etc/service/nginx/run /etc/service/haproxy/run && \
rm /etc/haproxy/haproxy.cfg && \
rm -rf /src

ENTRYPOINT ["tini"]
CMD ["/run.sh"]
