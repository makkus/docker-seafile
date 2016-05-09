#!/bin/bash

SEAFILE_GID=`grep "seafile gid" /tmp/ids.lst | cut -d ":" -f 2`
SEAFILE_UID=`grep "seafile uid" /tmp/ids.lst | cut -d ":" -f 2`
DB_GID=`grep "db gid" /tmp/ids.lst | cut -d ":" -f 2`
DB_UID=`grep "db uid" /tmp/ids.lst | cut -d ":" -f 2`


if [ -z "$SEAFILE_GID" ]
then
	SEAFILE_GID="1000"
	echo "XXXXX"
fi
echo "YYYYY"
if [ -z "$SEAFILE_UID" ]
then
	SEAFILE_UID="1000"
fi


# create seafile user
groupadd -o -g ${SEAFILE_GID} seafile
useradd seafile -o -d /opt/seafile -s /bin/bash -u ${SEAFILE_UID} -g ${SEAFILE_GID}





