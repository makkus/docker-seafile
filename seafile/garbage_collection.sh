#!/bin/sh


if [ ! "$ENABLE_GARBAGE_COLLECTION" = "True" ]
then
		echo "Garbage collection not enabled, exiting..."
		exit 0
fi

if [ ! -e /opt/seafile/seafile-setup-finished ]
then 
		echo "Seafile not setup yet, not running garbage collection. Exiting..."
		exit 0
fi

echo "Starting garbage collection..."

sv down seafile_services

/sbin/setuser seafile /opt/seafile/seafile-server-latest/seaf-gc.sh run

sv start seafile_services

echo "Garbage collection finished."

