FROM adhocore/phpfpm:8.1-rc

MAINTAINER Jitendra Adhikari <jiten.adhikary@gmail.com>

ENV \
  ADMINER_VERSION=4.8.1 \
  ES_HOME=/usr/share/java/elasticsearch \
  PATH=/usr/share/java/elasticsearch/bin:$PATH

RUN \
  # install
  apk add -U --no-cache \
    beanstalkd \
    # elasticsearch \
    memcached \
    mysql mysql-client \
    nano \
    nginx \
    postgresql \
    redis \
    supervisor \
  # elastic setup
  # && rm -rf $ES_HOME/plugins \
  #   && mkdir -p $ES_HOME/tmp $ES_HOME/data $ES_HOME/logs $ES_HOME/plugins $ES_HOME/config/scripts \
  #     && mv /etc/elasticsearch/* $ES_HOME/config/ \
  #   # elastico user
  #   && deluser elastico && addgroup -S elastico \
  #     && adduser -D -S -h /usr/share/java/elasticsearch -s /bin/ash -G elastico elastico \
  #     && chown elastico:elastico -R $ES_HOME \
  # rabbitmq
  # && echo @testing http://nl.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories \
    # && apk add -U rabbitmq-server@testing \
    # && apk add -U rabbitmq-server \
  # adminer
  && mkdir -p /var/www/adminer \
    && curl -sSLo /var/www/adminer/index.php \
      "https://github.com/vrana/adminer/releases/download/v$ADMINER_VERSION/adminer-$ADMINER_VERSION-en.php" \
  # cleanup
  && rm -rf /var/cache/apk/* /tmp/* /var/tmp/* /usr/share/doc/* /usr/share/man/*

# nginx config
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf

# mailcatcher
COPY --from=tophfr/mailcatcher /usr/lib/libruby.so.2.5 /usr/lib/libruby.so.2.5
COPY --from=tophfr/mailcatcher /usr/lib/ruby/ /usr/lib/ruby/
COPY --from=tophfr/mailcatcher /usr/bin/ruby /usr/bin/mailcatcher /usr/bin/

# resource
COPY php/index.php /var/www/html/index.php

# supervisor config
COPY \
  beanstalkd/beanstalkd.ini \
  # elasticsearch/elasticsearch.ini \
  mailcatcher/mailcatcher.ini \
  memcached/memcached.ini \
  mysql/mysql.ini \
  nginx/nginx.ini \
  pgsql/pgsql.ini \
  php/php-fpm.ini \
  # rabbitmq/rabbitmq.ini \
  redis/redis.ini \
    /etc/supervisor.d/

# entrypoint
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# ports
EXPOSE 11300 11211 9300 9200 9000 6379 5432 3306 88 80

# commands
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["supervisord", "-n", "-j", "/supervisord.pid"]
