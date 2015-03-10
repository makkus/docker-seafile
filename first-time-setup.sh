#!/bin/bash

if [ ! -e docker-compose.yml ]
then
	echo "No docker-compose.yml file, copying and using example..."
	cp docker-compose.yml.example docker-compose.yml
fi


echo "Stopping all potentially running containers..."
docker-compose stop
echo "Removing all potentially existing containers and volumes..."
docker-compose rm -v

echo "Checking certificate in 'nginx/certs'..."
if [ -e nginx/certs/cacert.pem ]
then 
		echo "Certificate exists (nginx/certs/cacert.pem), not creating new one..."
else
		echo "No certificate nginx/certs/cacert.pem, creating a self-signed one..."
		mkdir -p nginx/certs
		openssl genrsa -out nginx/certs/privkey.pem 2048
		openssl req -new -x509 -key nginx/certs/privkey.pem -out nginx/certs/cacert.pem -days 1095
		echo "Certificate created and put into 'nginx/certs'"
fi


echo "(Re-)Building images"
docker-compose build --no-cache

echo "Starting up containers..."
docker-compose up -d

sleep 5

if [ -e seahub_settings_template.py ]
then
		echo "seahub_settings_template.py exists, copying it to seahub container..."
		docker exec -i dockerseafile_seafile_1 /bin/bash -c 'cat > /opt/seafile/seahub_settings_template.py' < seahub_settings_template.py
else
		echo "No seahub_settings_template.py, doing nothing."
fi
docker exec -i -t dockerseafile_seafile_1 /sbin/setuser seafile /usr/local/bin/setup-seafile
