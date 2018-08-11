FROM phpearth/php:7.1-nginx

ENV HAPROXY_MAJOR=1.8 \
HAPROXY_VERSION=1.8.13 \
HAPROXY_SHA256=2bf5dafbb5f1530c0e67ab63666565de948591f8e0ee2a1d3c84c45e738220f1 \
LUA_VERSION=5.3.4 \
LUA_SHA1=79790cfd40e09ba796b01a571d4d63b52b1cd950 \
MUSL_LOCPATH=/usr/local/share/i18n/locales/musl \
PROXYSQL_VERSION=1.4.11

COPY haproxy-run /etc/service/haproxy/run
COPY proxysql-run /etc/service/proxysql/run
COPY nginx.conf /etc/nginx/nginx.conf
COPY www.conf /etc/php/7.1/php-fpm.d/www.conf

RUN set -x \
	\
	&& apk add --no-cache --virtual .build-deps \
		ca-certificates \
		gcc \
		g++ \
		libc-dev \
		linux-headers \
		make \
		openssl \
		openssl-dev \
		pcre-dev \
		readline-dev \
		tar \
		zlib-dev \
		cmake \
		musl-dev \
		gettext-dev \
		libintl \
		git \
		libexecinfo-dev \
		patch  \
		gawk \
	\
# install Lua
	&& wget -O lua.tar.gz "https://www.lua.org/ftp/lua-$LUA_VERSION.tar.gz" \
	&& echo "$LUA_SHA1 *lua.tar.gz" | sha1sum -c \
	&& mkdir -p /usr/src/lua \
	&& tar -xzf lua.tar.gz -C /usr/src/lua --strip-components=1 \
	&& rm lua.tar.gz \
	&& make -C /usr/src/lua -j "$(getconf _NPROCESSORS_ONLN)" linux \
	&& make -C /usr/src/lua install \
# put things we don't care about into a "trash" directory for purging
		INSTALL_BIN='/usr/src/lua/trash/bin' \
		INSTALL_CMOD='/usr/src/lua/trash/cmod' \
		INSTALL_LMOD='/usr/src/lua/trash/lmod' \
		INSTALL_MAN='/usr/src/lua/trash/man' \
# ... and since it builds static by default, put those bits somewhere we can purge after we build haproxy
		INSTALL_INC='/usr/local/lua-install/inc' \
		INSTALL_LIB='/usr/local/lua-install/lib' \
	&& rm -rf /usr/src/lua \
	\
# install HAProxy
	&& wget -O haproxy.tar.gz "https://www.haproxy.org/download/${HAPROXY_MAJOR}/src/haproxy-${HAPROXY_VERSION}.tar.gz" \
	&& echo "$HAPROXY_SHA256 *haproxy.tar.gz" | sha256sum -c \
	&& mkdir -p /usr/src/haproxy \
	&& tar -xzf haproxy.tar.gz -C /usr/src/haproxy --strip-components=1 \
	&& rm haproxy.tar.gz \
	\
	&& makeOpts=' \
		TARGET=linux2628 \
		USE_LUA=1 LUA_INC=/usr/local/lua-install/inc LUA_LIB=/usr/local/lua-install/lib \
		USE_OPENSSL=1 \
		USE_PCRE=1 PCREDIR= \
		USE_ZLIB=1 \
	' \
	&& make -C /usr/src/haproxy -j "$(getconf _NPROCESSORS_ONLN)" all $makeOpts \
	&& make -C /usr/src/haproxy install-bin $makeOpts \
	\
# install musl-locales with french
	&& cd /tmp \
	&& git clone https://github.com/vixns/musl-locales.git \
	&& cd musl-locales && cmake . && make && make install \
	&& cd /tmp && rm -rf musl-locales \
# install proxysql
	&& cd  /tmp \
	&& curl -sL https://github.com/sysown/proxysql/archive/${PROXYSQL_VERSION}.tar.gz | tar -zxf - \
	&& cd proxysql-${PROXYSQL_VERSION} \
	&& NOJEMALLOC=1 make \
	&& make install \
	&& cd /tmp \
	&& rm -rf proxysql-${PROXYSQL_VERSION} \
# purge the remnants of our static Lua
	&& rm -rf /usr/local/lua-install \
	\
	&& mkdir -p /etc/haproxy \
	&& cp -R /usr/src/haproxy/examples/errorfiles /etc/haproxy/errors \
	&& rm -rf /usr/src/haproxy \
	\
	&& runDeps="$( \
		scanelf --needed --nobanner --format '%n#p' --recursive /usr/local \
			| tr ',' '\n' \
			| sort -u \
			| awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
	)" \
&& apk add --virtual .haproxy-rundeps $runDeps libstdc++ \
&& apk del .build-deps \
&& chmod +x /etc/service/haproxy/run /etc/service/proxysql/run \
&& echo "date.timezone=UTC" >> "/etc/php/7.1/conf.d/timezone.ini" \
&& echo "pdo_mysql.default_socket=/run/mysql.sock" >> "/etc/php/7.1/conf.d/pdo_mysql.ini" \
&& echo "mysql.default_socket=/run/mysql.sock" >> "/etc/php/7.1/conf.d/mysql.ini" \
&& echo "mysqli.default_socket=/run/mysql.sock" >> "/etc/php/7.1/conf.d/mysqli.ini"
