## docker-lemp

> Do not use in Production.

A minimal single container LEMP full stack for local development.

It is quick jumpstart for onboarding you into docker based development.

The docker container `adhocore/lemp` is composed of:

Name        | Version    | Port
------------|------------|------
alpine      | 3.10       | -
PHP         | 7.4.0      | 9000
MySQL`*`    | 5.7        | 3306
PostgreSQL  | 11.6       | 5432
nginx       | 1.16.1     | 80
mailcatcher | 0.7.1      | 88
redis       | 5.0.5      | 6379
phalcon     | 4.0.0rc3   | -

> `*`: It is actually MariaDB.

## Usage

Install [docker](https://docs.docker.com/install/) in your machine.
Also recommended to install [docker-compose](https://docs.docker.com/compose/install/).

```sh
# pull latest image
docker pull adhocore/lemp:7.4

# Go to your project root then run
docker run -p 8080:80 -p 8888:88 -v `pwd`:/var/www/html --name lemp -d adhocore/lemp:7.4

# In windows, you would use %cd% instead of `pwd`
docker run -p 8080:80 -p 8888:88 -v %cd%:/var/www/html --name lemp -d adhocore/lemp:7.4

# If you want to setup MySQL credentials, pass env vars
docker run -p 8080:80 -p 8888:88 -v `pwd`:/var/www/html \
  -e MYSQL_ROOT_PASSWORD=1234567890 -e MYSQL_DATABASE=appdb \
  -e MYSQL_USER=dbuser -e MYSQL_PASSWORD=123456 \
  --name lemp -d adhocore/lemp:7.4
  # for postgres you can pass in similar env as for mysql but with PGSQL_ prefix
```

After running container as above, you will be able to browse [localhost:8080](http://localhost:8080)!

The database adminer will be available at [localhost:8080/adminer](http://localhost:8080/adminer).

The mailcatcher will be available at [localhost:8888](http://localhost:8888) which displays mails in realtime.

### Stop container

To stop the container, you would run:

```sh
docker stop lemp
```

### (Re)Start container

You dont have to always do `docker run` as in above unless you removed or lost your `lemp` container.

Instead, you can just start when needed:

```sh
docker start lemp
```

> **PRO** If you develop multiple apps, you can create multiple lemp containers with different names.
>
> eg: `docker run -p 8081:80 -v `pwd`:/var/www/html --name new-lemp -d adhocore/lemp:7.4`


## With Docker compose

Create a `docker-compose.yml` in your project root with contents something similar to:

```yaml
# ./docker-compose.yml
version: '3'

services:
  app:
    image: adhocore/lemp:7.4
    # For different app you can use different names. (eg: )
    container_name: some-app
    volumes:
      - db_data:/var/lib/mysql
      # Here you can also volume php ini settings
      # - /path/to/zz-overrides:/usr/local/etc/php/conf.d/zz-overrides.ini
    ports:
      - 8080:80
    environment:
      MYSQL_ROOT_PASSWORD: supersecurepwd
      MYSQL_DATABASE: appdb
      MYSQL_USER: dbusr
      MYSQL_PASSWORD: securepwd
      # for postgres you can pass in similar env as for mysql but with PGSQL_ prefix

volumes:
  db_data: {}
```

Then all you gotta do is:

```sh
# To start
docker-compose up -d

# To stop
docker-compose stop
```

As you can see using compose is very neat, intuitive and easy.
Plus you can already set the volumes and ports there, so you dont have to type in terminal.

### MySQL Default credentials

- **root password**: 1234567890 (if `MYSQL_ROOT_PASSWORD` is not passed)
- **user password**: 123456 (if `MYSQL_USER` is passed but `MYSQL_PASSWORD` is not)

#### Accessing DB
In PHP app you can access MySQL db via PDO like so:
```php
$db = new PDO(
    'mysql:host=127.0.0.1;port=3306;dbname=' . getenv('MYSQL_DATABASE'),
    getenv('MYSQL_USER'),
    getenv('MYSQL_PASSWORD')
);
```

You can access PgSQL db via PDO like so:
```php
$pdb = new PDO(
    'pgsql:host=127.0.0.1;port=5432;dbname=' . getenv('PGSQL_DATABASE'),
    getenv('PGSQL_USER'),
    getenv('PGSQL_PASSWORD')
);
```

### Nginx

URL rewrite is already enabled for you.
Either your app has `public/` folder or not, the rewrite adapts automatically.

### PHP

The following PHP extensions are installed:

```
bcmath
bz2
calendar
Core
ctype
curl
date
dom
exif
fileinfo
filter
ftp
gd
gettext
gmp
hash
iconv
imagick
intl
json
ldap
libxml
mbstring
mysqli
mysqlnd
openssl
pcre
PDO
pdo_mysql
pdo_sqlite
phalcon
Phar
posix
psr
readline
redis
Reflection
session
SimpleXML
soap
sodium
SPL
sqlite3
standard
tideways_xhprof
tokenizer
xdebug
xml
xmlreader
xmlwriter
yaml
Zend OPcache
zip
zlib
```

`phalcon` web framework `4.0.0-rc.3` has been installed.

Read more about [tideways](https://github.com/tideways/php-xhprof-extension),
[phalcon](https://github.com/phalcon/cphalcon) and [psr](https://github.com/jbboehr/php-psr).

### Testing mailcatcher

```sh
# open shell
docker exec -it lemp sh

# send test mail
echo "\n" | sendmail -S 0 test@localhost
```

Then you will see the new mail in realtime at http://localhost:8888.

Or you can see check it in shell as well:
```sh

curl 0:88/messages
```
