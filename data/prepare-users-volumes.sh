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


# create seafile user
groupadd -o -g ${SEAFILE_GID} seafile
useradd seafile -o -d /opt/seafile -s /bin/bash -u ${SEAFILE_UID} -g ${SEAFILE_GID}

groupadd -o -g ${DB_GID} mysql
useradd mysql -o -d /var/lib/mysql -s /bin/bash -u ${DB_UID} -g ${DB_GID}

mkdir /backup
mkdir /opt/seafile
mkdir /var/lib/seafile-data
mkdir /var/lib/mysql

chown -R seafile:seafile /opt/seafile
chown -R seafile:seafile /var/lib/seafile-data
chown -R mysql:mysql /var/lib/mysql
chown -R seafile:seafile /backup

echo "seafile gid:${SEAFILE_GID}" > /backup/ids.lst
echo "seafile uid:${SEAFILE_UID}" >> /backup/ids.lst
echo "db gid:${DB_GID}" >> /backup/ids.lst
echo "db uid:${DB_UID}" >> /backup/ids.lst

