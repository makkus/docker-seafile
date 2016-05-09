#!/bin/bash

set -e

/opt/seafile/setup-seafile.sqlite.sh

echo "Starting seafile..."
/opt/seafile/seafile-server-latest/seafile.sh start >> /var/log/seafile/seafile.log 2>&1
echo "Starting seahub..."
/opt/seafile/seafile-server-latest/seahub.sh start >> /var/log/seafile/seahub.log 2>&1

echo "All good! Everything running."
# Script should not exit unless seafile died
while pgrep -f "seafile-controller" 2>&1 >/dev/null; do

    if ! pgrep -f "gunicorn" 2>&1 > /dev/null
    then
        exit 1
    fi

    sleep 10;

done

exit 1
