FROM php:7.4.33-fpm-bullseye AS php-patch

COPY CVE-2026-109618-109619.patch /usr/src/php-fix.patch

# Rebuild 7.4.33 with the PHP team's EOL backport of CVE-2026-109618 and CVE-2026-109619.
# Bullseye LTS ended 2026-08-31; pin the last snapshot so apt still resolves.
RUN set -eux; \
    printf '%s\n' \
      'deb [check-valid-until=no] http://snapshot.debian.org/archive/debian/20260831T000000Z bullseye main' \
      'deb [check-valid-until=no] http://snapshot.debian.org/archive/debian-security/20260831T000000Z bullseye-security main' \
      > /etc/apt/sources.list; \
    rm -rf /etc/apt/sources.list.d; \
    echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99no-check-valid; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      $PHPIZE_DEPS patch \
      libargon2-dev libcurl4-openssl-dev libonig-dev libreadline-dev libsodium-dev \
      libsqlite3-dev libssl-dev libxml2-dev zlib1g-dev \
    ; \
    export CFLAGS="$PHP_CFLAGS" CPPFLAGS="$PHP_CPPFLAGS" LDFLAGS="$PHP_LDFLAGS"; \
    configureOptions="$(php-config --configure-options)"; \
    docker-php-source extract; \
    cd /usr/src/php; \
    patch -p1 --forward --no-backup-if-mismatch < /usr/src/php-fix.patch; \
    mkdir -p /out/usr/src; \
    tar -cJf /out/usr/src/php.tar.xz -C /usr/src --exclude=.docker-delete-me \
      --transform 's,^php,php-7.4.33,' php; \
    debMultiarch="$(dpkg-architecture --query DEB_BUILD_MULTIARCH)"; \
    if [ ! -e /usr/include/curl ] && [ ! -e /usr/local/include/curl ]; then \
      ln -sT "/usr/include/$debMultiarch/curl" /usr/local/include/curl; \
    fi; \
    ./configure $configureOptions; \
    make -j "$(nproc)"; \
    make INSTALL_ROOT=/out install-sapi install-binaries install-build \
      install-headers install-programs install-modules; \
    find /out -type f -perm '/0111' -exec strip --strip-all '{}' + || :

FROM php:7.4.33-fpm-bullseye

COPY --from=php-patch /out/ /

COPY haproxy-run /etc/service/haproxy/run
COPY proxysql-run /etc/service/proxysql/run
COPY nginx-run /etc/service/nginx/run
COPY php-run /etc/service/php-fpm/run
COPY run.sh /run.sh

ENV PROXYSQL_VERSION=2.7.3

RUN set -x \
    && export DEBIAN_FRONTEND=noninteractive \
    && printf '%s\n' \
      'deb [check-valid-until=no] http://snapshot.debian.org/archive/debian/20260831T000000Z bullseye main' \
      'deb [check-valid-until=no] http://snapshot.debian.org/archive/debian-security/20260831T000000Z bullseye-security main' \
      > /etc/apt/sources.list \
    && rm -rf /etc/apt/sources.list.d \
    && echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99no-check-valid \
    && rm -f /usr/src/php.tar.xz.asc \
    && apt update \
    && apt upgrade -y \
    && apt install --no-install-recommends  -y \
        haproxy \
        nginx \
        runit \
        tini \
        gnupg \
        procps \
        libfreetype-dev libjpeg62-turbo-dev libxml2-dev libpng-dev libjpeg-dev libwebp-dev \
&& curl -sL -o /tmp/proxysql.deb https://github.com/sysown/proxysql/releases/download/v${PROXYSQL_VERSION}/proxysql_${PROXYSQL_VERSION}-debian10_$(dpkg --print-architecture).deb \
&& dpkg -i /tmp/proxysql.deb \
&& rm /tmp/proxysql.deb \
&& docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp --enable-gd \
&& docker-php-ext-install gd \
&& dpkg --purge libfreetype-dev libjpeg62-turbo-dev libjpeg-dev libpng-dev libxml2-dev libwebp-dev \
&& apt autoremove -y \
&& rm -rf /var/lib/apt/* \
&& chmod +x /etc/service/haproxy/run /etc/service/proxysql/run /etc/service/nginx/run /etc/service/php-fpm/run \
&& rm -f /usr/local/etc/php-fpm.d/* /etc/haproxy/haproxy.cfg \
&& echo "date.timezone=UTC" >> "/usr/local/etc/php/conf.d/timezone.ini" \
&& echo "pdo_mysql.default_socket=/run/mysql.sock" >> "/usr/local/etc/php/conf.d/pdo_mysql.ini" \
&& echo "mysql.default_socket=/run/mysql.sock" >> "/usr/local/etc/php/conf.d/mysql.ini" \
&& echo "mysqli.default_socket=/run/mysql.sock" >> "/usr/local/etc/php/conf.d/mysqli.ini" \
&& echo "zend_extension=opcache.so" >> "/usr/local/etc/php/conf.d/ext-opcache.ini" \
&& echo "opcache.enable_cli=0" >> "/usr/local/etc/php/conf.d/ext-opcache.ini" \
&& echo "opcache.memory_consumption=128" >> "/usr/local/etc/php/conf.d/ext-opcache.ini" \
&& echo "opcache.interned_strings_buffer=8" >> "/usr/local/etc/php/conf.d/ext-opcache.ini" \
&& echo "opcache.max_accelerated_files=4000" >> "/usr/local/etc/php/conf.d/ext-opcache.ini" \
&& echo "opcache.fast_shutdown=1" >> "/usr/local/etc/php/conf.d/ext-opcache.ini" \
&& chmod +x /run.sh \
&& mkdir -p /var/lib/proxysql \
&& chown -R www-data /etc/service /var/lib/proxysql /etc/nginx /var/lib/nginx /var/log/nginx

COPY nginx.conf /etc/nginx/nginx.conf
COPY www.conf /usr/local/etc/php-fpm.d/www.conf
COPY php-fpm.conf /usr/local/etc/php-fpm.conf

USER www-data
ENTRYPOINT ["/usr/bin/tini"]
CMD ["/run.sh"]
