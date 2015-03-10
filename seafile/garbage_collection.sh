#!/bin/sh

OPTIND=1
FORCE_GC="False"

while getopts "f" opt; do
	case "$opt" in
	f) FORCE_GC="True"
	;;
	esac
done

if [ ! "$ENABLE_GARBAGE_COLLECTION" = "True" ] && [ ! "$FORCE_GC" = "True" ];
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

# just to make sure...
sleep 4

/sbin/setuser seafile /opt/seafile/seafile-server-latest/seaf-gc.sh run

sv start seafile_services

echo "Garbage collection finished."

