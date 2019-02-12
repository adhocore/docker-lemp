FROM php:7.3.1-fpm-alpine

MAINTAINER Jitendra Adhikari <jiten.adhikary@gmail.com>

RUN \
  PECL_EXTENSIONS="redis"; \
  PHP_EXTENSIONS="zip mysqli pdo_mysql pgsql pdo_pgsql opcache bcmath gd gmp intl ldap exif soap bz2 calendar"; \
  apk add -U --virtual temp autoconf g++ file re2c make zlib-dev libzip-dev libtool pcre-dev libpng-dev postgresql-dev gmp-dev icu-dev openldap-dev libxml2-dev bzip2-dev \
  && docker-php-source extract \
    && pecl channel-update pecl.php.net \
    && pecl install $PECL_EXTENSIONS \
    && docker-php-ext-enable $PECL_EXTENSIONS \
    && docker-php-ext-install $PHP_EXTENSIONS \
    && docker-php-source delete

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

RUN rm -rf /var/cache/apk/* /tmp/* /var/tmp/* /usr/share/doc/* /usr/share/man/*

COPY main.sh /entrypoint.sh
COPY mysql/mysqld.ini nginx/nginx.ini php/php-fpm.ini /etc/supervisor.d/
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf

# This doesnt seem to work only by making original file executable
RUN chmod +x /entrypoint.sh

EXPOSE 9000 3306 80

ENTRYPOINT ["/entrypoint.sh"]

CMD ["supervisord", "-n", "-j", "/supervisord.pid"]
