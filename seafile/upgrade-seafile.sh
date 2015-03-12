#!/bin/sh

# check this is run as the seafile user
if [ "$(id -u)" -eq "0" ]; then
   echo "This script must be run as user 'seafile'" 1>&2
	 exit 1
fi

SEAFILE_NEW_VERSION=$1

SEAFILE_TAR_FILE="seafile-server_${SEAFILE_NEW_VERSION}_x86-64.tar.gz"
SEAFILE_TAR_PATH="/opt/seafile/installed/${SEAFILE_TAR_FILE}"
SEAFILE_PATH="/opt/seafile/seafile-server-${SEAFILE_NEW_VERSION}"

if [ -z ${SEAFILE_NEW_VERSION} ]
then
	echo "No version specified, exiting..."
	exit 1
fi


echo "Downloading seafile, version $SEAFILE_NEW_VERSION"
if [ ! -f $SEAFILE_TAR_PATH ]
then
		mkdir -p /opt/seafile/temp
		cd /opt/seafile/temp && rm -f $SEAFILE_TAR_FILE

		curl -L -O "https://bitbucket.org/haiwen/seafile/downloads/${SEAFILE_TAR_FILE}"
		tar xzf seafile-server_*
		mv seafile-server-* /opt/seafile
		chown -R seafile /opt/seafile/seafile-server-*
		mkdir -p /opt/seafile/installed
		mv seafile-server_* /opt/seafile/installed
		chown -R seafile /opt/seafile/installed
fi

echo "Stopping services..."
sv stop  /etc/seafile/service/seahub
sv stop  /etc/seafile/service/seafile

cd ${SEAFILE_PATH}/upgrade

echo "\n========================================================================================================\n"
echo "Upgrade to version: ${SEAFILE_NEW_VERSION}\n"

cat << EOF
Entering upgrade shell, manual intervention needed. 

Check out the seafile upgrade instructions for details: http://manual.seafile.com/deploy/upgrade.html

If there is no upgrade script for the version you are targetting, you only need to run the 'minor-update.sh' script:

    ./minor-upgrade.sh
    exit

If there are update scripts, they usually do this for you (still worth checking after you run them). All you need to do is run the scripts incrementally, from your current version to the version you just installed. For example, you might need to run:

    ./upgrade_3.0_3.1.sh
    ./upgrade_3.1_4.0.sh
    exit


Ok, let's get started. This is the content of your current directory, containing all update scripts:

EOF

ls -lah

echo "\n========================================================================================================\n"

bash


echo "Update finished. Restarting services..."

sv start  /etc/seafile/service/seafile
sv start  /etc/seafile/service/seahub

echo "Services restarted"

