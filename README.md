> [!CAUTION]
> The author is no longer using Bludit, so it is being archived. If you want to change it, please fork it.
> 
> 作者がBluditを使わなくなったのでアーカイブ化します。変更したい人はフォークしてください。

# Flat file CMS Bludit with Debian 12(bookworm-slim), Lighttpd, FastCGI and PHP 8.2

This docker image Dockerfile is a Debian-based(bookworm-slim) Bludit docker image created with reference to the [official docker image configuration](https://github.com/bludit/docker/blob/master/Dockerfile).

It uses compact [lighttpd](https://www.lighttpd.net/) as the http server and runs PHP 8.2 with FastCGI.

## Information

* `FROM debian:bookworm-slim`
* Bludit 3.15.0
* Lighttpd 1.4.69 with FastCGI
* PHP 8.2

## Example

The following example shows forwarding to port 8000.

## docker

For easy startup, use the following command.

    $ docker run -dt -p 8000:80 --name bludit nogajun/bludit:latest

bludit is installed in /var/www/html. If you want to store contents or replace plugins or themes you can volume mount the directory.

    $ mkdir bl-content bl-plugins bl-themes
    $ docker run -dt -p 8000:80 \
      -v $(pwd)/bl-content:/var/www/html/bl-content \
      -v $(pwd)/bl-plugins:/var/www/html/bl-plugins \
      -v $(pwd)/bl-themes:/var/www/html/bl-themes \
      nogajun/bludit:latest

### docker-compose.yml

In the docker-compose.yml example, the directory should be created before execution because of the volume mount.

    $ mkdir bl-content bl-plugins bl-themes

The following is docker-compose.yml. `docker compose up -d` to start.

    services:
      bludit:
        image: nogajun/bludit
        container_name: bludit
        restart: always
        ports:
          - "8000:80"
        volumes:
          - ./bl-content:/var/www/html/bl-content
          - ./bl-plugins:/var/www/html/bl-plugins
          - ./bl-themes:/var/www/html/bl-themes
