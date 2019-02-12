FROM php:7.3.1-fpm-alpine

MAINTAINER Jitendra Adhikari <jiten.adhikary@gmail.com>

RUN apk add -U nano

RUN apk add mysql mysql-client

RUN \
  addgroup -S nginx \
    && adduser -D -S -h /var/cache/nginx -s /sbin/nologin -G nginx nginx \
    && mkdir -p /run/nginx /var/tmp/nginx/client_body \
    && chown nginx:nginx -R /run/nginx /var/tmp/nginx/ \
    && apk add nginx

RUN apk add supervisor

# RUN rm -rf /var/cache/apk/* /tmp/* /var/tmp/* /usr/share/doc/* /usr/share/man/*

COPY main.sh /entrypoint.sh
COPY mysql/mysqld.ini nginx/nginx.ini php/php-fpm.ini /etc/supervisor.d/
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf

# This doesnt seem to work only by making original file executable
RUN chmod +x /entrypoint.sh

EXPOSE 9000 3306 80

ENTRYPOINT ["/entrypoint.sh"]

CMD ["supervisord", "-n", "-j", "/supervisord.pid"]
