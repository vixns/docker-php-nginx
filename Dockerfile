FROM php:5.6-fpm
MAINTAINER Stéphane Cottin <stephane.cottin@vixns.com>

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62
RUN echo "deb http://nginx.org/packages/mainline/debian/ wheezy nginx" >> /etc/apt/sources.list

ENV NGINX_VERSION 1.7.11-1~wheezy

RUN apt-get update && \
	apt-get install -y ca-certificates nginx=${NGINX_VERSION} runit file re2c libicu-dev zlib1g-dev \
	libmcrypt-dev libfreetype6-dev libjpeg62-turbo-dev libicu52 libmcrypt4 g++ libgearman-dev \
	imagemagick libgeoip-dev libmemcached-dev libgraphicsmagick1-dev git libssl-dev && \
	rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-install sockets intl zip mbstring mcrypt gd

# install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN echo "date.timezone=UTC" >> "/usr/local/etc/php/conf.d/timezone.ini" && mkdir /usr/local/etc/php-fpm.d

RUN pecl install memcached gearman mongo geoip gmagick-beta && \
  echo "extension=gmagick.so" >> "/usr/local/etc/php/conf.d/ext-gmagick.ini" &&  \
  echo "extension=memcached.so" >> "/usr/local/etc/php/conf.d/ext-memcached.ini" &&  \
  echo "extension=gearman.so" >> "/usr/local/etc/php/conf.d/ext-gearman.ini" &&  \
  echo "extension=mongo.so" >> "/usr/local/etc/php/conf.d/ext-mongo.ini" &&  \
  echo "extension=geoip.so" >> "/usr/local/etc/php/conf.d/ext-geoip.ini" && \
  echo "zend_extension=opcache.so" >> "/usr/local/etc/php/conf.d/ext-opcache.ini" && \
  echo "opcache.enable_cli=1" >> "/usr/local/etc/php/conf.d/ext-opcache.ini" && \
  echo "opcache.memory_consumption=128" >> "/usr/local/etc/php/conf.d/ext-opcache.ini" && \
  echo "opcache.interned_strings_buffer=8" >> "/usr/local/etc/php/conf.d/ext-opcache.ini" && \
  echo "opcache.max_accelerated_files=4000" >> "/usr/local/etc/php/conf.d/ext-opcache.ini" && \
  echo "opcache.revalidate_freq=60" >> "/usr/local/etc/php/conf.d/ext-opcache.ini" && \
  echo "opcache.fast_shutdown=1" >> "/usr/local/etc/php/conf.d/ext-opcache.ini"

# forward request and error logs to docker log collector
RUN ln -sf /proc/1/fd/1 /var/log/nginx/access.log
RUN ln -sf /proc/1/fd/2 /var/log/nginx/error.log

COPY nginx.conf /etc/nginx/nginx.conf
COPY php-fpm.conf /usr/local/etc/
COPY www.conf /usr/local/etc/php-fpm.d/www.conf
COPY php-fpm.sh /etc/service/php-fpm/run
COPY nginx.sh /etc/service/nginx/run
COPY runsvdir-start.sh /usr/local/sbin/runsvdir-start

VOLUME ["/var/cache/nginx"]
EXPOSE 80

CMD ["/usr/local/sbin/runsvdir-start"]
