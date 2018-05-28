FROM php:7.0-fpm
COPY . /src
RUN \
echo "deb http://http.debian.net/debian stretch-backports contrib non-free main" >> /etc/apt/sources.list && \
apt-get update && apt-get --no-install-recommends -y dist-upgrade && \
apt-get install --no-install-recommends -y nginx runit libicu-dev zlib1g-dev libmcrypt-dev libmagickcore-dev libmagickwand-dev libmagick++-dev libmagickcore-6.q16-dev libjpeg-dev libpng-dev librsvg2-dev libicu57 libmcrypt4  imagemagick git libssl-dev xfonts-base xfonts-75dpi libfreetype6-dev procps && \
mkdir -p /usr/local/etc/php-fpm.d && \
docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/lib && docker-php-ext-install sockets intl zip mbstring mcrypt gd && \
pecl install imagick-beta && \
  echo "extension=imagick.so" >> "/usr/local/etc/php/conf.d/ext-imagick.ini" &&  \  
  echo "date.timezone=UTC" >> "/usr/local/etc/php/conf.d/timezone.ini" && \
  echo "zend_extension=opcache.so" >> "/usr/local/etc/php/conf.d/ext-opcache.ini" && \
  echo "opcache.enable_cli=1" >> "/usr/local/etc/php/conf.d/ext-opcache.ini" && \
  echo "opcache.memory_consumption=128" >> "/usr/local/etc/php/conf.d/ext-opcache.ini" && \
  echo "opcache.interned_strings_buffer=8" >> "/usr/local/etc/php/conf.d/ext-opcache.ini" && \
  echo "opcache.max_accelerated_files=4000" >> "/usr/local/etc/php/conf.d/ext-opcache.ini" && \
  echo "opcache.fast_shutdown=1" >> "/usr/local/etc/php/conf.d/ext-opcache.ini" && \
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
ln -sf /proc/1/fd/1 /var/log/nginx/access.log && \
ln -sf /proc/1/fd/2 /var/log/nginx/error.log && \
rm /usr/local/etc/php-fpm.d/*conf && \
apt-get update && apt-get -t stretch-backports -y install haproxy && \
curl -L -o /tmp/haproxy-1.8.8.tar.gz http://www.haproxy.org/download/1.8/src/haproxy-1.8.8.tar.gz && \
cd /tmp && tar zxf haproxy-1.8.8.tar.gz && cd haproxy-1.8.8 && \
make TARGET=linux2628 USE_PCRE=1 USE_OPENSSL=1 USE_ZLIB=1 && \
mv haproxy /usr/sbin/haproxy && cd /tmp && rm -rf haproxy* && \
dpkg --purge libicu-dev libxml2-dev libmagickcore-dev libmagickwand-dev libmagick++-dev libfreetype6-dev libmagickcore-6.q16-dev libgraphviz-dev libglib2.0-dev libtiff5-dev libwmf-dev libcairo2-dev libgdk-pixbuf2.0-dev libfontconfig1-dev librsvg2-dev libmagickwand-6.q16-dev libmagick++-6.q16-dev && \
rm -rf /var/lib/apt/lists/* && \
mkdir -p /etc/service/php-fpm/ && \
mkdir -p /etc/service/nginx/ /etc/service/haproxy/ && \
mv /src/policy.xml /etc/ImageMagick-6/policy.xml && \
mv /src/nginx.conf /etc/nginx/nginx.conf && \
mv /src/php-fpm.conf /usr/local/etc/php-fpm.conf && \
rm -f /usr/local/etc/php-fpm.d/* && \
mv /src/www.conf /usr/local/etc/php-fpm.d/www.conf && \
mv /src/php-fpm.sh /etc/service/php-fpm/run && \
mv /src/nginx.sh /etc/service/nginx/run && \
mv /src/haproxy.sh /etc/service/haproxy/run && \
mv /src/runsvdir-start.sh /sbin/runsvdir-start && \
ln -s /sbin/runsvdir-start /usr/local/sbin/runsvdir-start && \
rm /etc/haproxy/haproxy.cfg && \
rm -rf /src

EXPOSE 80

CMD ["/sbin/runsvdir-start"]
