FROM vixns/php-nginx:5.6

RUN \
  apt-get update \
  && apt-get install -y -t stretch-backports --no-install-recommends \
  libmemcached-dev default-libmysqlclient-dev \
  ssmtp mysql-client \
  && docker-php-ext-install pdo_mysql \
  && pecl install igbinary-2.0.8 \
  && echo "extension=igbinary.so" > "/usr/local/etc/php/conf.d/ext-igbinary.ini" \
  && mkdir -p /usr/src/php/ext \
  && curl -L http://pecl.php.net/get/memcached-2.2.0.tgz >> /usr/src/php/ext/memcached.tgz \
  && tar -xf /usr/src/php/ext/memcached.tgz -C /usr/src/php/ext/ \
  && rm /usr/src/php/ext/memcached.tgz \
  && docker-php-ext-configure memcached-2.2.0 --enable-memcached-igbinary \
  && docker-php-ext-install memcached-2.2.0 \
  && pecl install apcu-4.0.11 \
  && echo "extension=apcu.so" > /usr/local/etc/php/conf.d/apcu.ini \
  && curl -sL https://github.com/drush-ops/drush/releases/download/8.1.16/drush.phar -o /usr/local/bin/drush \
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
