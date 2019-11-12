FROM php:7.3.11-fpm-alpine3.10

MAINTAINER Jitendra Adhikari <jiten.adhikary@gmail.com>

ENV XHPROF_VERSION=5.0.1
ENV PHALCON_VERSION=3.4.4
ENV PECL_EXTENSIONS="redis yaml imagick xdebug"
ENV PHP_EXTENSIONS="bcmath bz2 calendar exif gd gettext gmp intl ldap mysqli opcache pdo_mysql soap zip"

RUN \
  # deps
  apk add -U --virtual temp \
    autoconf g++ file re2c make zlib-dev libtool pcre-dev libxml2-dev bzip2-dev libzip-dev \
      icu-dev gettext-dev imagemagick-dev openldap-dev libpng-dev gmp-dev yaml-dev \
    && apk add icu gettext imagemagick libzip libxml2-utils openldap yaml

RUN \
  # php extensions
  docker-php-source extract \
    && pecl channel-update pecl.php.net \
    && pecl install $PECL_EXTENSIONS \
    && docker-php-ext-enable ${PECL_EXTENSIONS//[-\.0-9]/} \
    && docker-php-ext-install $PHP_EXTENSIONS

RUN \
    # tideways_xhprof
    curl -sSLo /tmp/xhprof.tar.gz https://github.com/tideways/php-xhprof-extension/archive/v$XHPROF_VERSION.tar.gz \
      && tar xzf /tmp/xhprof.tar.gz && cd php-xhprof-extension-$XHPROF_VERSION \
      && phpize && ./configure \
      && make && make install \
      && docker-php-ext-enable tideways_xhprof \
      && cd .. && rm -rf php-xhprof-extension-$XHPROF_VERSION /tmp/xhprof.tar.gz \
    && docker-php-source delete

RUN \
  # phalcon
  curl -sSLo /tmp/phalcon.tar.gz https://codeload.github.com/phalcon/cphalcon/tar.gz/v$PHALCON_VERSION \
    && cd /tmp/ && tar xvzf phalcon.tar.gz \
    && cd cphalcon-$PHALCON_VERSION/build && sh install \
    && echo "extension=phalcon.so" > /usr/local/etc/php/conf.d/docker-php-ext-phalcon.ini

RUN curl -sSL https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN apk add -U nano

RUN apk add mysql mysql-client

RUN \
  addgroup -S nginx \
    && adduser -D -S -h /var/cache/nginx -s /sbin/nologin -G nginx nginx \
    && mkdir -p /run/nginx /var/tmp/nginx/client_body \
    && chown nginx:nginx -R /run/nginx /var/tmp/nginx/ \
    && apk add nginx

RUN apk add supervisor

RUN apk del temp \
  && rm -rf /var/cache/apk/* /tmp/* /var/tmp/* /usr/share/doc/* /usr/share/man/*

COPY main.sh /entrypoint.sh
COPY mysql/mysqld.ini nginx/nginx.ini php/php-fpm.ini /etc/supervisor.d/
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf

# This doesnt seem to work only by making original file executable
RUN chmod +x /entrypoint.sh

EXPOSE 9000 3306 80

ENTRYPOINT ["/entrypoint.sh"]

CMD ["supervisord", "-n", "-j", "/supervisord.pid"]
