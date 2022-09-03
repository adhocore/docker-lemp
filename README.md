## docker-lemp

[![Docker build](https://github.com/adhocore/docker-lemp/actions/workflows/build.yml/badge.svg)](https://github.com/adhocore/docker-lemp/actions/workflows/build.yml)
[![Donate 15](https://img.shields.io/badge/donate-paypal-blue.svg?style=flat-square&label=donate+15)](https://www.paypal.me/ji10/15usd)
[![Donate 25](https://img.shields.io/badge/donate-paypal-blue.svg?style=flat-square&label=donate+25)](https://www.paypal.me/ji10/25usd)
[![Donate 50](https://img.shields.io/badge/donate-paypal-blue.svg?style=flat-square&label=donate+50)](https://www.paypal.me/ji10/50usd)
[![Tweet](https://img.shields.io/twitter/url/http/shields.io.svg?style=social)](https://twitter.com/intent/tweet?text=Complete+LEMP+fullstack+for+local+development+using+docker&url=https://github.com/adhocore/docker-lemp&hashtags=docker,lemp,fullstack,localdev)


> Do not use this LEMP in Production.
> For production, use [adhocore/phpfpm](https://github.com/adhocore/docker-phpfpm)
> then [compose](https://docs.docker.com/compose/install/) a stack using individual `nginx`, `redis`, `mysql` etc images.

[`adhocore/lemp`](https://hub.docker.com/r/adhocore/lemp) is a minimal single container LEMP full stack for local development.

> If you want to use PHP7.4 on LEMP stack then head over to [`adhocore/lemp:7.4`](7.4.Dockerfile).

It is quick jumpstart for onboarding you into docker based development.
The download size is just about ~360MB which is tiny considering how much tools and stuffs it contains.

The docker container `adhocore/lemp` is composed of:

Name          | Version    | Port
--------------|------------|------
adminer       | 4.8.1      | 80
alpine        | 3.12       | -
beanstalkd    | 1.11       | 11300
elasticsearch`*` | 6.4.3      | 9200,9300
mailcatcher   | 0.7.1      | 88
memcached     | 1.6.6      | 11211
MySQL`**`     | 5.7        | 3306
nginx         | 1.18.0     | 80
phalcon       | 4.0.0      | -
PHP8.1        | 8.1.10     | 9000
PHP8.0        | 8.0.23     | 9000
PHP7.4        | 7.4.30     | 9000
PostgreSQL    | 12.6       | 5432
~rabbitmq~    | 3.8.*      | 5672
redis         | 5.0.11     | 6379
swoole        | 4.5.9      | -

> `*`: Latest versions of alpine (3.13+) seems to have removed `elasticsearch` binary!
> `**`: It is actually MariaDB 10.4.17.

## Usage

Install [docker](https://docs.docker.com/install/) in your machine.
Also recommended to install [docker-compose](https://docs.docker.com/compose/install/).

```sh
# pull latest image
docker pull adhocore/lemp:8.1

# or with PHP8.0
docker pull adhocore/lemp:8.0

# or if you use php 7.4, replace 8.0 with 7.4:
docker pull adhocore/lemp:7.4

# Go to your project root then run
docker run -p 8080:80 -p 8888:88 -v `pwd`:/var/www/html --name lemp -d adhocore/lemp:8.0

# In windows, you would use %cd% instead of `pwd`
docker run -p 8080:80 -p 8888:88 -v %cd%:/var/www/html --name lemp -d adhocore/lemp:8.0

# If you want to setup MySQL credentials, pass env vars
docker run -p 8080:80 -p 8888:88 -v `pwd`:/var/www/html \
  -e MYSQL_ROOT_PASSWORD=1234567890 -e MYSQL_DATABASE=appdb \
  -e MYSQL_USER=dbuser -e MYSQL_PASSWORD=123456 \
  --name lemp -d adhocore/lemp:8.0
  # for postgres you can pass in similar env as for mysql but with PGSQL_ prefix
```

After running container as above, you will be able to browse [localhost:8080](http://localhost:8080)!

The database adminer will be available for [mysql](http://localhost:8080/adminer?server=127.0.0.1%3A3306&username=root)
and [postgres](http://localhost:8080/adminer?pgsql=127.0.0.1%3A5432&username=postgres).

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
> eg: `docker run -p 8081:80 -v $(pwd):/var/www/html --name new-lemp -d adhocore/lemp:8.0`


## With Docker compose

Create a `docker-compose.yml` in your project root with contents something similar to:

```yaml
# ./docker-compose.yml
version: '3'

services:
  app:
    image: adhocore/lemp:8.0
    # For different app you can use different names. (eg: )
    container_name: some-app
    volumes:
      # app source code
      - ./path/to/your/app:/var/www/html
      # db data persistence
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

### PgSQL Default credentials

- **postgres password**: 1234567890 (if `PGSQL_ROOT_PASSWORD` is not passed)
- **user password**: 123456 (if `PGSQL_USER` is passed but `PGSQL_PASSWORD` is not)


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

For available extensions, check [adhocore/phpfpm#extension](https://github.com/adhocore/docker-phpfpm/tree/8.0#extensions).

### Disabling services

[Pass in env var](https://www.cloudsavvyit.com/14081/how-to-pass-environment-variables-to-docker-containers/)
`DISABLE` to the container in CSV format to disable services.
The service names must be one or more of below in comma separated format:
```
beanstalkd
mailcatcher
memcached
mysql
pgsql
redis
```

> Example: `DISABLE=beanstalkd,mailcatcher,memcached,pgsql,redis`
> Essential services like `nginx`, `php`, `adminer` cannot be disabled ;).

The service(s) will be enabled again if you run the container next time without `DISABLE` env or if you remove specific services from `DISABLE` CSV.

### Testing mailcatcher

```sh
# open shell
docker exec -it lemp sh

# send test mail
echo "\n" | sendmail -S 0 test@localhost
```

Then you will see the new mail in realtime at http://localhost:8888.

Or you can check it in shell as well:
```sh

curl 0:88/messages
```
