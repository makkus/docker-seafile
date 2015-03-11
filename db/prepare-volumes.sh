#!/bin/bash

if [ -z "$DB_GID" ]
then
	DB_GID="1000"
fi
if [ -z "$DB_UID" ]
then
	DB_UID="1000"
fi

groupadd -g ${DB_GID} mysql
useradd mysql -d /var/lib/mysql -s /bin/bash -u ${DB_UID} -g ${DB_GID}
