#!/bin/sh

exec 2>&1
exec /sbin/setuser seafile runsvdir -P /etc/seafile/service 'log:....................'
EOF
