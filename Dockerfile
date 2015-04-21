FROM php:5.6-fpm
MAINTAINER Stéphane Cottin <stephane.cottin@vixns.com>

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62
RUN echo "deb http://nginx.org/packages/mainline/debian/ wheezy nginx" >> /etc/apt/sources.list

ENV NGINX_VERSION 1.7.12-1~wheezy

RUN apt-get update && \
	apt-get install -y ca-certificates nginx=${NGINX_VERSION} runit file re2c libicu-dev zlib1g-dev \
	libmcrypt-dev libmagickcore-dev libmagickwand-dev libmagick++-dev libicu52 libmcrypt4 g++ \
  xvfb wkhtmltopdf imagemagick git libssl-dev && \
  mkdir /usr/local/etc/php-fpm.d && \
	rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-install sockets intl zip mbstring mcrypt gd

RUN pecl install imagick-beta && \
  echo "extension=imagick.so" >> "/usr/local/etc/php/conf.d/ext-imagick.ini" &&  \  
  echo "date.timezone=UTC" >> "/usr/local/etc/php/conf.d/timezone.ini" && \
  echo "zend_extension=opcache.so" >> "/usr/local/etc/php/conf.d/ext-opcache.ini" && \
  echo "opcache.enable_cli=1" >> "/usr/local/etc/php/conf.d/ext-opcache.ini" && \
  echo "opcache.memory_consumption=128" >> "/usr/local/etc/php/conf.d/ext-opcache.ini" && \
  echo "opcache.interned_strings_buffer=8" >> "/usr/local/etc/php/conf.d/ext-opcache.ini" && \
  echo "opcache.max_accelerated_files=4000" >> "/usr/local/etc/php/conf.d/ext-opcache.ini" && \
  echo "opcache.fast_shutdown=1" >> "/usr/local/etc/php/conf.d/ext-opcache.ini"

# install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# forward request and error logs to docker log collector
RUN ln -sf /proc/1/fd/1 /var/log/nginx/access.log
RUN ln -sf /proc/1/fd/2 /var/log/nginx/error.log

COPY nginx.conf /etc/nginx/nginx.conf
COPY php-fpm.conf /usr/local/etc/
COPY www.conf /usr/local/etc/php-fpm.d/www.conf
COPY php-fpm.sh /etc/service/php-fpm/run
COPY nginx.sh /etc/service/nginx/run
COPY wkhtmltopdf.sh /usr/local/bin/wkhtmltopdf
COPY wkhtmltoimage.sh /usr/local/bin/wkhtmltoimage
COPY runsvdir-start.sh /usr/local/sbin/runsvdir-start

VOLUME ["/var/cache/nginx"]
EXPOSE 80

CMD ["/usr/local/sbin/runsvdir-start"]
