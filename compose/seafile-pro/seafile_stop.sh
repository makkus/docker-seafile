#!/bin/sh

[ -e /opt/seafile/seafile-setup-finished ] || exit 0

/opt/seafile/seafile-server-latest/seafile.sh stop >>/var/log/seafile/seafile.log 2>&1
