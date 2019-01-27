FROM php:7.3.1-fpm-alpine

MAINTAINER Jitendra Adhikari <jiten.adhikary@gmail.com>

RUN \
  mkdir -p /run/mysqld \
  && apk add -U mysql mysql-client --no-cache \
  && mysql_install_db

RUN \
  addgroup -S nginx \
  && adduser -D -S -h /var/cache/nginx -s /sbin/nologin -G nginx nginx \
  && mkdir -p /run/nginx \
  && apk add nginx --no-cache

RUN \
  apk add supervisor --no-cache

RUN \
  rm -rf /var/cache/apk/* /tmp/* /var/tmp/* \
  && rm -rf /usr/share/doc/* /usr/share/man/*

COPY main.sh /main.sh
COPY mysql/mysqld.ini nginx/nginx.ini php/php-fpm.ini /etc/supervisor.d/

EXPOSE 9000 3306 80

ENTRYPOINT ["/main.sh"]

CMD ["supervisord", "-n", "-j", "/supervisord.pid"]
