#!/bin/sh

MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD:-1234567890}
MYSQL_PASSWORD=${MYSQL_PASSWORD:-123456}

# init mysql
if [ ! -f "/run/mysqld/.init" ]; then
  mkdir -p /run/mysqld /var/lib/mysql
  chown mysql:mysql -R /run/mysqld /var/lib/mysql

  mysql_install_db --user=mysql

  SQL=""

  if [ -n "$MYSQL_DATABASE" ]; then
    SQL="CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE CHARACTER SET utf8 COLLATE utf8_general_ci;"
  fi

  SQL="DELETE FROM mysql.user WHERE Password = ''"

  if [ -n "MYSQL_USER" ]; then
    mysql -u root -e "GRANT ALL ON *.* to '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD'"
  fi

  mysqladmin -u root password $MYSQL_ROOT_PASSWORD
  mysqladmin -u root -h '%' password $MYSQL_ROOT_PASSWORD

  mysql -u root -p$MYSQL_ROOT_PASSWORD -e "FLUSH PRIVILEGES"

  touch /run/mysqld/.init
fi

exec "$@"
