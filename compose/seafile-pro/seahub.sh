#!/bin/sh

[ -e /opt/seafile/seafile-setup-finished ] || exit 0

SEAFILE_FASTCGI_HOST='0.0.0.0' /opt/seafile/seafile-server-latest/seahub.sh start-fastcgi >>/var/log/seafile/seahub.log 2>&1

# Script should not exit unless seahub died
while pgrep -f "manage.py run" 2>&1 >/dev/null; do
	sleep 10;
done

exit 1
