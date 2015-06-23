#!/bin/bash

if [ ! -e docker-compose.yml ]
then
	echo "No docker-compose.yml file, copying and using example..."
	cp docker-compose.yml.example.nginx docker-compose.yml
fi


echo "Stopping all potentially running containers..."
docker-compose stop
echo "Removing all potentially existing containers and volumes..."
docker-compose rm -v

WEBSERVER="nginx"

grep "^\s*build: apache_shib" docker-compose.yml

if [ $? -eq 0 ]; then
		echo "Using apache with shibboleth configuration."
		WEBSERVER="apache"
else
		grep "^\s*build: apache" docker-compose.yml
		if [ $? -eq 0 ]; then
  		echo "Using apache configuration."
	  	WEBSERVER="apache"
		else
		  echo "Using nginx configuration."
		fi
fi

echo "Checking certificate in $WEBSERVER/certs..."
if [ -e "$WEBSERVER/certs/cacert.pem" ]
then 
		echo "Certificate exists ($WEBSERVER/certs/cacert.pem), not creating new one..."
else
		echo "No certificate $WEBSERVER/certs/cacert.pem, creating a self-signed one..."
		mkdir -p "$WEBSERVER/certs"
		openssl genrsa -out "$WEBSERVER/certs/privkey.pem" 2048
		openssl req -new -x509 -key "$WEBSERVER/certs/privkey.pem" -out "$WEBSERVER/certs/cacert.pem" -days 1095
		echo "Certificate created and put into $WEBSERVER/certs"
fi


echo "(Re-)Building images"
cp ids.lst data/ids.lst
cp ids.lst db/ids.lst
cp ids.lst seafile/ids.lst
docker-compose build --no-cache
rm data/ids.lst
rm db/ids.lst
rm seafile/ids.lst

echo "Starting up containers..."
docker-compose up -d

sleep 5

if [ -e seahub_settings_template.py ]
then
		echo "seahub_settings_template.py exists, copying it to seahub container..."
		docker exec -i dockerseafile_seafile_1 /bin/bash -c 'cat > /opt/seafile/seahub_settings_template.py' < seahub_settings_template.py
else
		echo "No seahub_settings_template.py, doing nothing."
# FIXME: 

echo "Changing owners for volumes..."

docker exec -i -t dockerseafile_data_1 /root/volume-permissions.sh

echo "Starting setup process..."

docker exec -i -t dockerseafile_seafile_1 /sbin/setuser seafile /usr/local/bin/setup-seafile
