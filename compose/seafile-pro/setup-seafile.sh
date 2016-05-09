#!/bin/bash

if [ -e /opt/seafile/seafile-setup-finished ]
then 
		echo "File: '/opt/seafile/seafile-setup-finished' exists, which means seafile is already setup. Doing nothing."
		exit 0
fi

# check this is run as the seafile user
if [ "$(id -u)" -eq "0" ]; then
   echo "This script must be run as user 'seafile'" 1>&2
	 exit 1
fi

echo "Checking whether database already exist, ignore potential error messages"
mysqlshow --user=${SEAFILE_DB_USER} --password=${SEAFILE_DB_PASSWORD} --host db ccnet
if [ ! $? -eq 0 ]
then
		echo "Creating databases using 'admin' and mariadb account."
		# seems we need to sleep for a while, until mariadb is ready
		until mysqladmin -h db -p"$DB_ENV_MARIADB_PASS" -u admin version
		do 
				echo "Waiting for mariadb to become ready..."
				sleep 1
		done
			 
		echo "Creating databases..."
		mysql -u admin -p"$DB_ENV_MARIADB_PASS" -h db -e "set @username='${SEAFILE_DB_USER}';set @password='${SEAFILE_DB_PASSWORD}'; source /opt/scripts/create_db.sql;"
		if [ $? -eq 0 ]; then
				echo "Databases created successfully"
		else
				echo "Could not create databases. Exiting..."
				exit 1
		fi
fi

SEAFILE_TAR_FILE="seafile-pro-server_${SEAFILE_VERSION}_x86-64.tar.gz"
SEAFILE_TAR_PATH="/opt/seafile/installed/${SEAFILE_TAR_FILE}"
SEAFILE_PATH="/opt/seafile/seafile-pro-server-${SEAFILE_VERSION}"

echo "Downloading seafile, version $SEAFILE_VERSION"
if [ ! -f $SEAFILE_TAR_PATH ]
then
		mkdir -p /opt/seafile/temp
    cd /opt/seafile/temp && rm -f $SEAFILE_TAR_FILE
    wget "https://cloud.seafile.de/d/$TOKEN/files/?p=/latest/$SEAFILE_TAR_FILE&dl=1" -O "/opt/seafile/temp/$SEAFILE_TAR_FILE"
    # cp "/tmp/$SEAFILE_TAR_FILE" /opt/seafile/temp/
		# curl -L -O "https://bintray.com/artifact/download/seafile-org/seafile/${SEAFILE_TAR_FILE}"
		tar xzf seafile-pro-server_*
		mv seafile-pro-server-* /opt/seafile
		chown -R seafile /opt/seafile/seafile-pro-server-*
		mkdir -p /opt/seafile/installed
		mv seafile-pro-server_* /opt/seafile/installed
		chown -R seafile /opt/seafile/installed
fi

# check whether users already exist, if, we assume we don't need to run the setup
EXISTING_USERS=$(mysql --user ${SEAFILE_DB_USER} -p${SEAFILE_DB_PASSWORD} -h db -Dccnet -se "SELECT COUNT(*) FROM EmailUser")
if [ ! $? -eq 0 ] 
then
		if [ -x ${SEAFILE_PATH}/setup-seafile-mysql.sh ]
		then
				echo "Starting seafile installation..."
				SEAFILE_CLEAN_TITLE=${SEAFILE_SITE_TITLE// /_}
				/usr/local/bin/setup-seafile.expect "$SEAFILE_VERSION" "$SEAFILE_CLEAN_TITLE" "$SEAFILE_HOSTNAME" "$SEAFILE_DB_USER" "$SEAFILE_DB_PASSWORD"
				#${SEAFILE_PATH}/setup-seafile-mysql.sh
				
				# check whether setup was successful
				if [ -e /opt/seafile/ccnet/seafile.ini ]
				then
						# start seafile interactively so admin account can be created
						${SEAFILE_PATH}/seafile.sh start
						${SEAFILE_PATH}/seahub.sh start
						${SEAFILE_PATH}/seahub.sh stop
						${SEAFILE_PATH}/seafile.sh stop

						# now that the admin user is created and seafile was started once, we can move the seafile data dir to its own volume
						DIR=`cat /opt/seafile/ccnet/seafile.ini`
						echo "Moving seafile data dir from $DIR to /var/lib/seafile-data..."
						mv $DIR/* /var/lib/seafile-data/
						echo /var/lib/seafile-data > /opt/seafile/ccnet/seafile.ini
						rmdir /opt/seafile/seafile-data

						# copying custom seafile install data
						mkdir -p "$SEAFILE_PATH/seahub/media/custom"
						cp -r /tmp/seafile-custom/* "$SEAFILE_PATH/seahub/media/custom"

						# changing url: http://manual.seafile.com/deploy/deploy_seahub_at_non-root_domain.html
            echo "FILE_SERVER_ROOT = \"https://${SEAFILE_HOSTNAME}/seafhttp\"" >> /opt/seafile/conf/seahub_settings.py
						if [ -z ${SEAFILE_SITE_ROOT} ]
						then
                sed -i -e "s/SERVICE_URL.*/SERVICE_URL = https:\/\/${SEAFILE_HOSTNAME}/" /opt/seafile/conf/ccnet.conf
						else
                sed -i -e "s/SERVICE_URL.*/SERVICE_URL = https:\/\/${SEAFILE_HOSTNAME}\/${SEAFILE_SITE_ROOT}/" /opt/seafile/conf/ccnet.conf
						fi
            echo "SERVE_STATIC = False" >> /opt/seafile/conf/seahub_settings.py
            echo "MEDIA_URL = '/seafmedia/'" >> /opt/seafile/conf/seahub_settings.py
            echo "COMPRESS_URL = MEDIA_URL" >> /opt/seafile/conf/seahub_settings.py
            echo "STATIC_URL = MEDIA_URL+'assets/'" >> /opt/seafile/conf/seahub_settings.py
						
						if [ ! -z ${SEAFILE_SITE_ROOT} ] 
						then 
                echo "SITE_ROOT = '/${SEAFILE_SITE_ROOT}/'" >> /opt/seafile/conf/seahub_settings.py
                echo "SITE_BASE = 'https://${SEAFILE_HOSTNAME}/${SEAFILE_SITE_ROOT}'" >> /opt/seafile/conf/seahub_settings.py
                echo "LOGIN_URL = '/${SEAFILE_SITE_ROOT}/accounts/login/'" >> /opt/seafile/conf/seahub_settings.py
						fi

						# other settings
            echo "SITE_NAME = '${SEAFILE_HOSTNAME}'" >> /opt/seafile/conf/seahub_settings.py
            echo "SITE_TITLE = '${SEAFILE_SITE_TITLE}'" >> /opt/seafile/conf/seahub_settings.py
						
						# add template, if it exists
						if [ -e /opt/seafile/seahub_settings_template.py ]
						then
                cat /opt/seafile/seahub_settings_template.py >> /opt/seafile/conf/seahub_settings.py
						fi
						
						# setup webdav: http://manual.seafile.com/extension/webdav.html
						sed -i -e "s/enabled.*/enabled = true/" /opt/seafile/conf/seafdav.conf
						sed -i -e "s/port.*/port = 8081/" /opt/seafile/conf/seafdav.conf
						sed -i -e "s/fastcgi.*/fastcgi = true/" /opt/seafile/conf/seafdav.conf
						sed -i -e "s/share_name.*/share_name = \/seafdav/" /opt/seafile/conf/seafdav.conf

						# setup office conversion
            sed -i -e "s/enabled = false/enabled = true/" /opt/seafile/conf/seafevents.conf
            sed -i -e "s/index_office_pdf.*/index_office_pdf = true/" /opt/seafile/conf/seafevents.conf
				fi
		fi
fi

chmod o-r /opt/seafile/conf/seahub_settings.py

echo "Everything setup. The url of your installation is: 'https://${SEAFILE_HOSTNAME}/${SEAFILE_SITE_ROOT}'"

# TODO run all the checks again?
# signal to runit that service can be started
touch /opt/seafile/seafile-setup-finished
