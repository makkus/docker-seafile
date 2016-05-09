#!/bin/sh

OPTIND=1
FORCE_BACKUP="False"

while getopts "f" opt; do
        case "$opt" in
        f) FORCE_BACKUP="True"
        ;;
        esac
done


if [ ! "$ENABLE_BACKUP" = "True" ] && [ ! "$FORCE_BACKUP" = "True" ];
then
		echo "Backup not enabled, exiting..."
		exit 0
fi

if [ ! -e /opt/seafile/seafile-setup-finished ]
then 
		echo "Seafile not setup yet, not backing up anything. Exiting..."
		exit 0
fi

echo "Backup enabled, starting..."

DB_DIR="/backup/seafile/db"
DATA_DIR="/backup/seafile/data"
APP_DIR="/backup/seafile/application"

mkdir -p "$DB_DIR"
mkdir -p "$DATA_DIR"
mkdir -p "$APP_DIR"

echo "Backing up db"
mysqldump -h db -u${SEAFILE_DB_USER} -p${SEAFILE_DB_PASSWORD} --opt ccnet > $DB_DIR/ccnet.sql.`date +"%Y-%m-%d-%H-%M-%S"`
mysqldump -h db -u${SEAFILE_DB_USER} -p${SEAFILE_DB_PASSWORD} --opt seafile > $DB_DIR/seafile.sql.`date +"%Y-%m-%d-%H-%M-%S"`
mysqldump -h db -u${SEAFILE_DB_USER} -p${SEAFILE_DB_PASSWORD} --opt seahub > $DB_DIR/seahub.sql.`date +"%Y-%m-%d-%H-%M-%S"`


echo "Backing up application directory"
BUP_DIR=/backup/seafile/application bup init
BUP_DIR=/backup/seafile/application bup index /opt/seafile/
BUP_DIR=/backup/seafile/application bup save -n seafile_app /opt/seafile/


echo "Backing up data directory: $DATA_DIR"
rsync -az /var/lib/seafile-data "$DATA_DIR"
