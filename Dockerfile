FROM debian:bullseye-slim

LABEL version="1.1"
LABEL maintainer="nogajun@gmail.com"
LABEL description="Debian-based bludit image using lighttpd."

ARG bludit_version="3-14-1"
ARG bludit_url="https://www.bludit.com/releases/bludit-${bludit_version}.zip"
ARG php_version="7.4"
ARG php_ini="/etc/php/${php_version}/cgi/php.ini"

RUN apt-get -y update && \
    apt-get -y dist-upgrade && \
    apt-get -y install lighttpd php php-cgi php-fdomdocument php-gd php-mbstring php-zip php-json php-xml unzip curl && \
    apt-get -y autoremove && apt-get -y clean && rm -rf /var/lib/apt/lists/*

# lighttpd modules
RUN lighttpd-enable-mod accesslog deflate rewrite fastcgi-php && \
    echo 'url.rewrite-if-not-file = ( "^/(.*)" => "/index.php?q=$1" )' >> /etc/lighttpd/conf-available/10-rewrite.conf && \
    install -o www-data -g www-data -m 750 -d /run/lighttpd && \
    gpasswd -a www-data tty

# Config files
RUN sed -i -e "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=1/g" ${php_ini} && \
    sed -i -e "s/upload_max_filesize\s*=\s*2M/upload_max_filesize = 100M/g" ${php_ini} && \
    sed -i -e "s/post_max_size\s*=\s*8M/post_max_size = 100M/g" ${php_ini} && \
    sed -i -e "s/variables_order = \"GPCS\"/variables_order = \"EGPCS\"/g" ${php_ini} && \
    sed -i -e "s/memory_limit = 128M/memory_limit = -1/g" ${php_ini}

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/lighttpd/access.log && \
    ln -sf /dev/stderr /var/log/lighttpd/error.log

# bludit installation
WORKDIR /var/www
RUN rm -rf html && \
    curl -o bludit.zip ${bludit_url} && \
    unzip bludit.zip && \
    mv bludit html && \
    chown -R www-data:www-data html && \
    sed -i -e "s/'DEBUG_MODE', FALSE/'DEBUG_MODE', TRUE/g" html/bl-kernel/boot/init.php && \
    rm bludit.zip

EXPOSE 80

CMD ["lighttpd", "-D", "-f", "/etc/lighttpd/lighttpd.conf"]
