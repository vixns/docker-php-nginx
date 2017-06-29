FROM phpearth/php:7.1-nginx
COPY . /src
RUN echo "date.timezone=UTC" >> "/etc/php/conf.d/timezone.ini" \
&& mv /src/nginx.conf /etc/nginx/nginx.conf \
&& mv /src/www.conf /etc/php/php-fpm.d/www.conf \
&& rm -rf /src
