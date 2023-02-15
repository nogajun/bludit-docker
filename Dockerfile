FROM debian:bullseye-slim

LABEL version="1.2"
LABEL maintainer="nogajun@gmail.com"
LABEL description="Debian-based bludit image using lighttpd."

ARG PHP_VERSION="7.4"

# package installtion
RUN apt-get -y update && \
    apt-get -y dist-upgrade && \
    apt-get -y install lighttpd php php-cgi php-fdomdocument php-gd php-mbstring php-zip php-json php-xml curl && \
    apt-get -y autoremove && apt-get -y clean && rm -rf /var/lib/apt/lists/*

# set up lighttpd modules
RUN lighttpd-enable-mod accesslog deflate rewrite fastcgi-php && \
    echo 'url.rewrite-if-not-file = ( "^/(.*)" => "/index.php?q=$1" )' >> /etc/lighttpd/conf-available/10-rewrite.conf && \
    sed -i -e 's|/var/log/lighttpd/access.log|/tmp/logpipe|g' /etc/lighttpd/conf-available/10-accesslog.conf && \
    install -o www-data -g www-data -m 750 -d /run/lighttpd && \
    rm /var/www/html/index.lighttpd.html && \
    mkdir -p /var/www/html/bl-content/

# set up php.ini
RUN sed -i -e \
    's|;cgi.fix_pathinfo=1|cgi.fix_pathinfo=1|g; \
     s|upload_max_filesize = 2M|upload_max_filesize = 100M|g; \
     s|post_max_size = 8M|post_max_size = 100M|g; \
     s|variables_order = "GPCS"|variables_order = "EGPCS"|g; \
     s|memory_limit = 128M|memory_limit = -1|g' /etc/php/${PHP_VERSION}/cgi/php.ini

# bludit installation
WORKDIR /var/www/html
RUN BLUDIT_VERSION=$(curl -s https://api.github.com/repos/bludit/bludit/releases/latest | grep tag_name - | cut -d"\"" -f4) && \
    curl https://codeload.github.com/bludit/bludit/tar.gz/refs/tags/${BLUDIT_VERSION} | tar xz -C . --strip-components 1 \
    --exclude='*/.gitignore' \
    --exclude='*/.github' \
    --exclude='*/README.md' \
    --exclude='*/LICENSE' && \
    chown -R www-data:www-data /var/www/html
#    sed -i -e "s|'DEBUG_MODE', FALSE|'DEBUG_MODE', TRUE|g" /var/www/html/bl-kernel/boot/init.php

# set volume
VOLUME /var/www/html/bl-content

# Copy start up scpript
COPY start.sh /usr/local/bin/

EXPOSE 80

CMD ["start.sh"]
