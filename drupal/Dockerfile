FROM vixns/php-nginx:5.6-drush

WORKDIR /data/htdocs

# https://www.drupal.org/node/3060/release
ENV DRUPAL_VERSION 7.38
ENV DRUPAL_MD5 c18298c1a5aed32ddbdac605fdef7fce

RUN curl -fSL "http://ftp.drupal.org/files/projects/drupal-${DRUPAL_VERSION}.tar.gz" -o drupal.tar.gz \
  && echo "${DRUPAL_MD5} *drupal.tar.gz" | md5sum -c - \
  && tar -xz --strip-components=1 -f drupal.tar.gz \
  && rm drupal.tar.gz \
  && chown -R www-data:www-data sites