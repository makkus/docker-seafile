#!/bin/sh

[ -e /opt/seafile/seafile-setup-finished ] || exit 0

# Fix for https://github.com/haiwen/seafile/issues/478, forward seafdav localhost-only port
[ "${workaround478}" = 'true' ] && socat TCP4-LISTEN:8080,fork TCP4:localhost:8081 &

/opt/seafile/seafile-server-latest/seafile.sh start >>/var/log/seafile/seafile.log 2>&1

# Script should not exit unless seafile died
while pgrep -f "seafile-controller" 2>&1 >/dev/null; do

	sleep 10;

done
exit 1
