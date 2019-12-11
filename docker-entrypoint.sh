#!/bin/sh

MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD:-1234567890}
MYSQL_PASSWORD=${MYSQL_PASSWORD:-123456}

PGSQL_ROOT_PASSWORD=${PGSQL_ROOT_PASSWORD:-1234567890}
PGSQL_PASSWORD=${PGSQL_PASSWORD:-123456}

# init nginx
if [ ! -d "/var/tmp/nginx/client_body" ]; then
  mkdir -p /run/nginx /var/tmp/nginx/client_body
  chown nginx:nginx -R /run/nginx /var/tmp/nginx/
fi

# init mysql
if [ ! -f "/run/mysqld/.init" ]; then
  [[ "$MYSQL_USER" = "root" ]] && echo "Please set MYSQL_USER other than root" && exit 1

  SQL=$(mktemp)

  mkdir -p /run/mysqld /var/lib/mysql
  chown mysql:mysql -R /run/mysqld /var/lib/mysql
  sed -i -e 's/skip-networking/skip-networking=0/' /etc/my.cnf.d/mariadb-server.cnf
  mysql_install_db --user=mysql --datadir=/var/lib/mysql

  if [ -n "$MYSQL_DATABASE" ]; then
    echo "CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE CHARACTER SET utf8 COLLATE utf8_general_ci;" >> $SQL
  fi

  MYSQL_DATABASE=${MYSQL_DATABASE:-*}

  if [ -n "MYSQL_USER" ]; then
    echo "GRANT ALL ON $MYSQL_DATABASE.* to '$MYSQL_USER'@'localhost' IDENTIFIED BY '$MYSQL_PASSWORD';" >> $SQL
    echo "GRANT ALL ON $MYSQL_DATABASE.* to '$MYSQL_USER'@'127.0.0.1' IDENTIFIED BY '$MYSQL_PASSWORD';" >> $SQL
    echo "GRANT ALL ON $MYSQL_DATABASE.* to '$MYSQL_USER'@'::1' IDENTIFIED BY '$MYSQL_PASSWORD';" >> $SQL
  fi

  echo "UPDATE mysql.user SET Password=PASSWORD('$MYSQL_ROOT_PASSWORD') WHERE User='root';" >> $SQL
  echo "DELETE FROM mysql.user WHERE User = '' OR Password = '';" >> $SQL
  echo "FLUSH PRIVILEGES;" >> $SQL

  cat "$SQL" | mysqld --user=mysql --bootstrap --silent-startup --skip-grant-tables=FALSE

  rm -rf ~/.mysql_history ~/.ash_history $SQL
  touch /run/mysqld/.init
fi

# init pgsql
if [ ! -f /run/postgresql/.init ]; then
  [[ "$PGSQL_USER" = "postgres" ]] && echo "Please set PGSQL_USER other than postgres" && exit 1

  SQL=$(mktemp)

  mkdir -p /run/postgresql /usr/local/pgsql/data
  chown postgres:postgres -R /run/postgresql /usr/local/pgsql/data $SQL
  su postgres -c "initdb -D /usr/local/pgsql/data"

  PGSQL_DATABASE=${PGSQL_DATABASE:-test}
  echo "CREATE DATABASE $PGSQL_DATABASE;" >> $SQL
  echo "ALTER USER postgres PASSWORD '$PGSQL_ROOT_PASSWORD';" >> $SQL
  if [ -n "$PGSQL_USER" ]; then
    echo "CREATE USER $PGSQL_USER WITH ENCRYPTED PASSWORD '$PGSQL_PASSWORD';" >> $SQL
    echo "GRANT ALL PRIVILEGES ON DATABASE $PGSQL_DATABASE TO $PGSQL_USER;" >> $SQL
  fi
  echo "GRANT ALL PRIVILEGES ON DATABASE $PGSQL_DATABASE TO postgres;" >> $SQL

  su postgres -c "pg_ctl -D '/usr/local/pgsql/data' -o '-c listen_addresses='' -p ${PGSQL_PORT:-5432}' -w start"
  su postgres -c "psql -f '$SQL'"
  rm -rf ~/.psql_history ~/.ash_history $SQL
  su postgres -c "pg_ctl -D '/usr/local/pgsql/data' -m fast -w stop"
  sed -i -E 's/host\s+all(.*)trust/host    all\1password/' /usr/local/pgsql/data/pg_hba.conf
  touch /run/postgresql/.init
fi

exec "$@"
