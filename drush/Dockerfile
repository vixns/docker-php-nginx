FROM vixns/php-nginx:5.6
MAINTAINER Stéphane Cottin <stephane.cottin@vixns.com>

ENV DRUSH_VERSION 6.x

RUN apt-get update && \
	apt-get install -y ssmtp libmysqlclient-dev &&\
	rm -rf /var/lib/apt/lists/*

RUN CPPFLAGS=-I/usr/include/mysql pecl install pdo_mysql && \
  echo "extension=pdo_mysql.so" >> "/usr/local/etc/php/conf.d/ext-pdo_mysql.ini"

RUN git clone -b $DRUSH_VERSION https://github.com/drush-ops/drush.git /usr/src/drush && cd /usr/src/drush && ln -s /usr/src/drush/drush /usr/bin/drush && composer install