# Debian-based bludit docker image with official docker image configuration

This docker image Dockerfile is a Debian-based bludit docker image created with reference to the [official docker image configuration](https://github.com/bludit/docker/blob/master/Dockerfile).

It uses compact [lighttpd](https://www.lighttpd.net/) as the http server and runs PHP with Fast CGI.

## Information

* `FROM debian:bullseye-slim`
* Bludit 3.14.1
* Lighttpd 1.4.59 with Fast CGI
* PHP 7.4


