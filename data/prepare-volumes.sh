#!/bin/bash

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
	DB_GID="1000"
fi
if [ -z "$DB_UID" ]
then
	DB_UID="1000"
fi
if [ -z "$BACKUP_GID" ]
then
	BACKUP_GID="1000"
fi
if [ -z "$BACKUP_UID" ]
then
	BACKUP_UID="1000"
fi


# create seafile user
groupadd -o -g ${SEAFILE_GID} seafile
useradd seafile -o -d /opt/seafile -s /bin/bash -u ${SEAFILE_UID} -g ${SEAFILE_GID}

groupadd -o -g ${DB_GID} mysql
useradd mysql -o -d /var/lib/mysql -s /bin/bash -u ${DB_UID} -g ${DB_GID}

groupadd -o -g ${BACKUP_GID} seafile_backup
useradd seafile_backup -o -d /backup -s /bin/bash -u ${BACKUP_UID} -g ${BACKUP_GID}

mkdir /backup
mkdir /opt/seafile
mkdir /var/lib/seafile-data
mkdir /var/lib/mysql

chown -R seafile:seafile /opt/seafile
chown -R seafile:seafile /var/lib/seafile-data
chown -R mysql:mysql /var/lib/mysql
chown -R backup:backup /backup

echo "seafile gid:${SEAFILE_GID}" > /backup/ids.lst
echo "seafile uid:${SEAFILE_UID}" >> /backup/ids.lst
echo "db gid:${DB_GID}" >> /backup/ids.lst
echo "db uid:${DB_UID}" >> /backup/ids.lst
echo "backup gid:${BACKUP_GID}" >> /backup/ids.lst
echo "backup uid:${BACKUP_UID}" >> /backup/ids.lst
