#!/bin/sh

[ -e /opt/seafile/seafile-setup-finished ] || exit 0

/opt/seafile/seafile-server-latest/seahub.sh stop >>/var/log/seafile/seahub.log 2>&1
