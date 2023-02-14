FROM debian:bullseye-slim

LABEL version="1.2"
LABEL maintainer="nogajun@gmail.com"
LABEL description="Debian-based bludit image using lighttpd."

ARG bludit_version="3.14.1"
ARG bludit_url="https://codeload.github.com/bludit/bludit/tar.gz/refs/tags/${bludit_version}"
ARG php_version="7.4"
ARG php_ini="/etc/php/${php_version}/cgi/php.ini"

RUN apt-get -y update && \
    apt-get -y dist-upgrade && \
    apt-get -y install lighttpd php php-cgi php-fdomdocument php-gd php-mbstring php-zip php-json php-xml curl && \
    apt-get -y autoremove && apt-get -y clean && rm -rf /var/lib/apt/lists/*

# lighttpd modules
RUN lighttpd-enable-mod accesslog deflate rewrite fastcgi-php && \
    echo 'url.rewrite-if-not-file = ( "^/(.*)" => "/index.php?q=$1" )' >> /etc/lighttpd/conf-available/10-rewrite.conf && \
    sed -i -e 's|/var/log/lighttpd/access.log|/tmp/logpipe|g' /etc/lighttpd/conf-available/10-accesslog.conf && \
    install -o www-data -g www-data -m 750 -d /run/lighttpd 

# Config files
RUN sed -i -e 's|;cgi.fix_pathinfo=1|cgi.fix_pathinfo=1|g' ${php_ini} && \
    sed -i -e 's|upload_max_filesize = 2M|upload_max_filesize = 100M|g' ${php_ini} && \
    sed -i -e 's|post_max_size = 8M|post_max_size = 100M|g' ${php_ini} && \
    sed -i -e 's|variables_order = "GPCS"|variables_order = "EGPCS"|g' ${php_ini} && \
    sed -i -e 's|memory_limit = 128M|memory_limit = -1|g' ${php_ini}

# bludit installation
WORKDIR /var/www
RUN rm -rf html && \
    mkdir -p html/bl-content/ && \
    curl ${bludit_url} | tar xz -C html --strip-components 1 && \
    chown -R www-data:www-data html && \
    sed -i -e "s/'DEBUG_MODE', FALSE/'DEBUG_MODE', TRUE/g" html/bl-kernel/boot/init.php 

VOLUME ["/var/www/html/bl-content","/var/www/html/bl-themes","/var/www/html/bl-plugins"]

# Copy start up scpript
COPY start.sh /usr/local/bin/

EXPOSE 80

CMD ["start.sh"]

