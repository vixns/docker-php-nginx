FROM vixns/php-nginx:5.6

ENV PHLACON_VERSION 1.3.4

RUN git clone -b $PHLACON_VERSION https://github.com/phalcon/cphalcon.git /usr/src/cphalcon && cd /usr/src/cphalcon/build && ./install && echo "extension=phalcon.so" >> "/usr/local/etc/php/conf.d/ext-phalcon.ini" && rm -rf /usr/src/cphalcon
