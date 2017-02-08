FROM vixns/php-nginx:5.6

RUN \
  apt-get update \
  && apt-get install -y -t jessie-backports --no-install-recommends \
  libmemcached-dev libmysqlclient-dev \
  ssmtp libmysqlclient-dev mysql-client \
  && docker-php-ext-install pdo_mysql \
  && pecl install igbinary \
  && echo "extension=igbinary.so" > "/usr/local/etc/php/conf.d/ext-igbinary.ini" \
  && mkdir -p /usr/src/php/ext \
  && curl -L http://pecl.php.net/get/memcached-2.2.0.tgz >> /usr/src/php/ext/memcached.tgz \
  && tar -xf /usr/src/php/ext/memcached.tgz -C /usr/src/php/ext/ \
  && rm /usr/src/php/ext/memcached.tgz \
  && docker-php-ext-configure memcached-2.2.0 --enable-memcached-igbinary \
  && docker-php-ext-install memcached-2.2.0 \
  && pecl install apcu-4.0.11 \
  && echo "extension=apcu.so" > /usr/local/etc/php/conf.d/apcu.ini \
  && php -r "readfile('https://s3.amazonaws.com/files.drush.org/drush.phar');" > /usr/local/bin/drush \
  && chmod 755 /usr/local/bin/drush \
  && export VERSION=`php -r "echo PHP_MAJOR_VERSION.PHP_MINOR_VERSION;"` \
  && curl -A "Docker" -o /tmp/blackfire-probe.tar.gz -D - -L -s https://blackfire.io/api/v1/releases/probe/php/linux/amd64/${VERSION} \
  && tar zxpf /tmp/blackfire-probe.tar.gz -C /tmp \
  && mv /tmp/blackfire-*.so `php -r "echo ini_get('extension_dir');"`/blackfire.so \
  && echo "extension=blackfire.so\nblackfire.agent_socket=\${BLACKFIRE_PORT}" > /usr/local/etc/php/conf.d/blackfire.ini && rm -rf /tmp/black* \
  && rm -rf /var/lib/apt/lists/*

COPY ssmtp.conf /etc/ssmtp/ssmtp.conf
COPY ssmtp.ini /usr/local/etc/php/conf.d/ssmtp.ini
COPY run.sh /etc/service/php-fpm/run
