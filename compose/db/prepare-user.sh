#!/bin/bash

SEAFILE_GID=`grep "seafile gid" /tmp/ids.lst | cut -d ":" -f 2`
SEAFILE_UID=`grep "seafile uid" /tmp/ids.lst | cut -d ":" -f 2`
DB_GID=`grep "db gid" /tmp/ids.lst | cut -d ":" -f 2`
DB_UID=`grep "db uid" /tmp/ids.lst | cut -d ":" -f 2`


if [ -z "$SEAFILE_GID" ]
then
	SEAFILE_GID="1000"
fi
if [ -z "$SEAFILE_UID" ]
then
	SEAFILE_UID="1000"
fi
if [ -z "$DB_GID" ]
then
	DB_GID=$SEAFILE_GID
fi
if [ -z "$DB_UID" ]
then
	DB_UID=$SEAFILE_UID
fi

groupadd -o -g ${DB_GID} mysql
useradd mysql -o -d /var/lib/mysql -s /bin/bash -u ${DB_UID} -g ${DB_GID}

