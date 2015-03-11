#!/bin/bash

if [ -z "$SEAFILE_GID" ]
then
	SEAFILE_GID="1000"
fi
if [ -z "$SEAFILE_UID" ]
then
	SEAFILE_UID="1000"
fi


# create seafile user
groupadd -o -g ${SEAFILE_GID} seafile
useradd seafile -o -d /opt/seafile -s /bin/bash -u ${SEAFILE_UID} -g ${SEAFILE_GID}



