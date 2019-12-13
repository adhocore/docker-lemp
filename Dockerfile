FROM adhocore/phpfpm:7.4

MAINTAINER Jitendra Adhikari <jiten.adhikary@gmail.com>

# nano
RUN apk add -U nano

# mysql
RUN apk add mysql mysql-client

# pgsql
RUN apk add postgresql

# nginx
RUN \
  addgroup -S nginx \
    && adduser -D -S -h /var/cache/nginx -s /sbin/nologin -G nginx nginx \
    && mkdir -p /run/nginx /var/tmp/nginx/client_body \
    && chown nginx:nginx -R /run/nginx /var/tmp/nginx/ \
    && apk add nginx

# supervisor
RUN apk add supervisor

# supervisor config
COPY docker-entrypoint.sh /docker-entrypoint.sh
COPY mysql/mysqld.ini nginx/nginx.ini php/php-fpm.ini pgsql/postgres.ini mail/mailcatcher.ini /etc/supervisor.d/
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf

# adminer
RUN \
  mkdir -p /var/www/adminer \
  && curl -sSLo /var/www/adminer/index.php $(curl -s https://api.github.com/repos/vrana/adminer/releases/latest \
    | grep 'browser_download_url.*\d-en.php' -m 1 | cut -d : -f 2,3 | tr -d \" \ )

# mailcatcher
COPY --from=tophfr/mailcatcher /usr/lib/libruby.so.2.5 /usr/lib/libruby.so.2.5
COPY --from=tophfr/mailcatcher /usr/lib/ruby/ /usr/lib/ruby/
COPY --from=tophfr/mailcatcher /usr/bin/ruby /usr/bin/mailcatcher /usr/bin/

# resource
COPY php/index.php /var/www/html/index.php

# This doesnt seem to work only by making original file executable
RUN chmod +x /docker-entrypoint.sh

# cleanup
RUN \
  rm -rf /var/cache/apk/* /tmp/* /var/tmp/* /usr/share/doc/* /usr/share/man/*

EXPOSE 9000 5432 3306 88 80

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["supervisord", "-n", "-j", "/supervisord.pid"]
