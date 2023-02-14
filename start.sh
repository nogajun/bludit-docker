#!/bin/sh
# from https://redmine.lighttpd.net/issues/2731#note-15
mkfifo -m 600 /tmp/logpipe
cat <> /tmp/logpipe 1>&2 &
chown www-data /tmp/logpipe
exec /usr/sbin/lighttpd -D -f /etc/lighttpd/lighttpd.conf 2>&1
