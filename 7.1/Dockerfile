FROM phpearth/php:7.1-nginx
COPY . /src
RUN echo "date.timezone=UTC" >> "/etc/php/7.1/conf.d/timezone.ini" \
&& mv /src/nginx.conf /etc/nginx/nginx.conf \
&& mv /src/www.conf /etc/php/7.1/php-fpm.d/www.conf \
&& rm -rf /src
