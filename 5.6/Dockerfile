FROM php:5.6-fpm
COPY . /src
ENV TINI_VERSION=v0.18.0 TINI_SUBREAPER=1
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-static-amd64 /tini
ENTRYPOINT ["/tini", "--"]

RUN \
chmod +x /tini && \
echo "deb http://http.debian.net/debian stretch-backports contrib non-free main" >> /etc/apt/sources.list && \
apt-get update && apt-get --no-install-recommends -t stretch-backports -y dist-upgrade && \
apt-get install --no-install-recommends -t stretch-backports -y ca-certificates haproxy procps nginx runit file re2c libicu-dev zlib1g-dev libmcrypt-dev libmagickcore-dev libmagickwand-dev libmagick++-dev libjpeg-dev libpng-dev libicu57 libmcrypt4 g++ imagemagick git libssl-dev xfonts-base xfonts-75dpi libfreetype6-dev && \
mkdir -p /usr/local/etc/php-fpm.d && \
curl -s -L -o /tmp/wkhtmltox.deb https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.stretch_amd64.deb && \
dpkg -i /tmp/wkhtmltox.deb && rm /tmp/wkhtmltox.deb && \
# install proxysql
curl -sL -o /tmp/proxysql_2.0.0-debian9_amd64.deb https://github.com/vixns/proxysql/releases/download/v2.0.0-beta.1/proxysql_2.0.0-debian9_amd64.deb && \
dpkg -i /tmp/proxysql_2.0.0-debian9_amd64.deb && \
rm /tmp/proxysql_2.0.0-debian9_amd64.deb && \
docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/lib && docker-php-ext-install sockets intl zip mbstring mcrypt gd && \
pecl install imagick && \
  echo "extension=imagick.so" >> "/usr/local/etc/php/conf.d/ext-imagick.ini" &&  \
  echo "date.timezone=UTC" >> "/usr/local/etc/php/conf.d/timezone.ini" && \
  echo "zend_extension=opcache.so" >> "/usr/local/etc/php/conf.d/ext-opcache.ini" && \
  echo "opcache.enable_cli=1" >> "/usr/local/etc/php/conf.d/ext-opcache.ini" && \
  echo "opcache.memory_consumption=192" >> "/usr/local/etc/php/conf.d/ext-opcache.ini" && \
  echo "opcache.interned_strings_buffer=16" >> "/usr/local/etc/php/conf.d/ext-opcache.ini" && \
  echo "opcache.max_accelerated_files=7963" >> "/usr/local/etc/php/conf.d/ext-opcache.ini" && \
  echo "opcache.fast_shutdown=1" >> "/usr/local/etc/php/conf.d/ext-opcache.ini" && \
  echo "pdo_mysql.default_socket=/run/mysql.sock" >> "/usr/local/etc/php/conf.d/pdo_mysql.ini" && \
  echo "mysql.default_socket=/run/mysql.sock" >> "/usr/local/etc/php/conf.d/mysql.ini" && \
  echo "mysqli.default_socket=/run/mysql.sock" >> "/usr/local/etc/php/conf.d/mysqli.ini" && \
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
ln -sf /proc/1/fd/1 /var/log/nginx/access.log && \
ln -sf /proc/1/fd/2 /var/log/nginx/error.log && \
rm /usr/local/etc/php-fpm.d/*conf && \
dpkg --purge libicu-dev libmagickcore-dev libmagickwand-dev libmagick++-dev libssl-dev libfreetype6-dev libmagickcore-6.q16-dev libgraphviz-dev libglib2.0-dev libtiff5-dev libwmf-dev libcairo2-dev libgdk-pixbuf2.0-dev libfontconfig1-dev librsvg2-dev libmagickwand-6.q16-dev libmagick++-6.q16-dev libxml2-dev && \
apt-get autoremove -y && \
rm -rf /var/lib/apt/lists/* && \
mkdir -p /etc/service/php-fpm/ && \
mkdir -p /etc/service/nginx/ && \
mkdir -p /etc/service/proxysql/ && \
mkdir -p /etc/service/haproxy/ && \
mv /src/haproxy.sh /etc/service/haproxy/run && \
mv /src/proxysql.sh /etc/service/proxysql/run && \
mv /src/policy.xml /etc/ImageMagick-6/policy.xml && \
mv /src/nginx.conf /etc/nginx/nginx.conf && \
mv /src/php-fpm.conf /usr/local/etc/php-fpm.conf && \
rm -f /usr/local/etc/php-fpm.d/* /etc/haproxy/haproxy.cfg && \
mv /src/www.conf /usr/local/etc/php-fpm.d/www.conf && \
mv /src/php-fpm.sh /etc/service/php-fpm/run && \
mv /src/nginx.sh /etc/service/nginx/run && \
mv /src/runsvdir-start.sh /usr/local/sbin/runsvdir-start && \
chmod +x /etc/service/haproxy/run /etc/service/proxysql/run /etc/service/nginx/run /etc/service/php-fpm/run  && \
rm -rf /src

CMD ["/usr/local/sbin/runsvdir-start"]
