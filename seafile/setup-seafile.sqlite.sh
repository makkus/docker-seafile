#!/bin/bash

set -e

PUID=${PUID:-1000}
PGID=${PGID:-1000}

if [ ! "$(id -u seafile)" -eq "$PUID" ]; then usermod -o -u "$PUID" seafile ; fi
if [ ! "$(id -g seafile)" -eq "$PGID" ]; then groupmod -o -g "$PGID" seafile ; fi

chown -R seafile:seafile /seafile
chown -R seafile:seafile /opt/seafile
chown -R seafile:seafile /var/log/seafile


# check this is run as the seafile user
if [ "$(id -u)" -eq "0" ]; then
   echo "This script must be run as user 'seafile'" 1>&2
	 exit 1
fi

[ -z "${SEAFILE_VERSION}" ] && SEAFILE_VERSION="5.1.1"
[ -z "${SEAFILE_HOSTNAME}"] && SEAFILE_HOSTNAME="localhost"
[ -z "${SEAFILE_SITE_ROOT}"] && SEAFILE_SITE_ROOT=""
[ -z "${SEAFILE_SITE_TITLE}"] && SEAFILE_SITE_TITLE="My Seafile"

SEAFILE_TAR_FILE="seafile-server_${SEAFILE_VERSION}_x86-64.tar.gz"
SEAFILE_TAR_PATH="/seafile/packages/${SEAFILE_TAR_FILE}"
SEAFILE_PATH="/opt/seafile/seafile-server-${SEAFILE_VERSION}"

# Additional properties
declare -a properties=("EMAIL_USE_TLS"
                "EMAIL_HOST"
                "EMAIL_HOST_USER"
                "EMAIL_HOST_PASSWORD"
                "EMAIL_PORT"
                "DEFAULT_FROM_EMAIL"
                "SERVER_EMAIL"
                "ENABLE_SIGNUP"
                "ACTIVATE_AFTER_REGISTRATION"
                "SEND_EMAIL_ON_ADDING_SYSTEM_MEMBER"
                "SEND_EMAIL_ON_RESETTING_USER_PASSWD"
                "LOGIN_REMEMBER_DAYS"
                "LOGIN_ATTEMPT_LIMIT"
                "FREEZE_USER_ON_LOGIN_FAILED"
                "USER_PASSWORD_MIN_LENGTH"
                "USER_PASSWORD_STRENGTH_LEVEL"
                "USER_STRONG_PASSWORD_REQUIRED"
                "FORCE_PASSWORD_CHANGE"
                "SESSION_COOKIE_AGE"
                "SESSION_EXPIRE_AT_BROWSER_CLOSE"
                "SESSION_SAVE_EVERY_REQUEST"
                "REPO_PASSWORD_MIN_LENGTH"
                "SHARE_LINK_PASSWORD_MIN_LENGTH"
                "DISABLE_SYNC_WITH_ANY_FOLDER"
                "ENABLE_REPO_HISTORY_SETTING"
                "ENABLE_USER_CREATE_ORG_REPO"
                "USE_PDFJS"
                "FILE_PREVIEW_MAX_SIZE"
                "ENABLE_THUMBNAIL"
                "THUMBNAIL_ROOT"
                "CLOUD_MODE"
                "ENABLE_GLOBAL_ADDRESSBOOK"
                "TIME_ZONE"
                "LANGUAGE_CODE"
                "SHOW_TRAFFIC"
                "ENABLE_SYS_ADMIN_VIEW_REPO"
                "LOGO_PATH"
                "LOGO_WIDTH"
                "LOGO_HEIGHT"
                "BRANDING_CSS")




if [ ! -f ${SEAFILE_TAR_PATH} ]
then
    echo "Downloading seafile, version ${SEAFILE_VERSION}"
    mkdir -p /opt/seafile/temp
		cd /opt/seafile/temp && rm -f *

		curl -L -O "https://bintray.com/artifact/download/seafile-org/seafile/${SEAFILE_TAR_FILE}"
    mkdir -p /seafile/packages
    mv /opt/seafile/temp/${SEAFILE_TAR_FILE} ${SEAFILE_TAR_PATH}
    rm -f /seafile/packages/seafile-current.tar.gz
    ln -s ${SEAFILE_TAR_PATH} /seafile/packages/seafile-current.tar.gz
    chown -R seafile:seafile ${SEAFILE_TAR_PATH}
    echo "Download finished"
fi

if [ ! -d ${SEAFILE_PATH} ]
then
    echo "Extracting seafile app."
    # TODO: check for version when container volume deleted
    tar xzf /seafile/packages/seafile-current.tar.gz  -C /opt/seafile
    chown -R seafile:seafile ${SEAFILE_PATH}
fi

if [ ! -e /seafile/conf ]
then
    echo "Folder: '/seafile/conf' does not exists, which means seafile is not setup yet."

    echo "Starting seafile installation..."
    SEAFILE_CLEAN_TITLE=${SEAFILE_SITE_TITLE// /_}

    /opt/seafile/setup-seafile.sqlite.expect "${SEAFILE_VERSION}" "${SEAFILE_CLEAN_TITLE}" "${SEAFILE_HOSTNAME}"

    # check whether setup was successful
    if [ -e /opt/seafile/ccnet/seafile.ini ]
    then
        # start seafile interactively so admin account can be created
        ${SEAFILE_PATH}/seafile.sh start
        ${SEAFILE_PATH}/seahub.sh start
        ${SEAFILE_PATH}/seahub.sh stop
        ${SEAFILE_PATH}/seafile.sh stop

        # creating seahub_settings.py
        for i in "${properties[@]}"
        do
            if [ ! -z "${!i}" ]
            then
                echo "${i} = ${!i}" >> /opt/seafile/conf/seahub_settings.py
            fi
        done

        # now that the admin user is created and seafile was started once, we can move the seafile data dir to its own volume
        DIR=`cat /opt/seafile/ccnet/seafile.ini`
        echo "Moving seafile data dir from $DIR to /var/lib/seafile-data..."
        mkdir -p /seafile/data
        mv $DIR/* /seafile/data/
        echo /seafile/data > /opt/seafile/ccnet/seafile.ini
        rmdir /opt/seafile/seafile-data

        # copying custom seafile install data
        # mkdir -p "${SEAFILE_PATH}/seahub/media/custom"
        # cp -r /tmp/seafile-custom/* "${SEAFILE_PATH}/seahub/media/custom"

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
    fi

    chmod o-r /opt/seafile/conf/seahub_settings.py

    # Moving stuff out of the /opt/seafile directory, so app & config data is separated
    mv /opt/seafile/ccnet /seafile/ccnet

    mv /opt/seafile/conf  /seafile/conf

    mv /opt/seafile/logs/*  /var/log/seafile/
    rmdir /opt/seafile/logs

    mv /opt/seafile/seahub.db /seafile/seahub.db

    mv /opt/seafile/seahub-data /seafile/seahub-data

    echo "Everything setup. The url of your installation is: 'https://${SEAFILE_HOSTNAME}/${SEAFILE_SITE_ROOT}'"

fi

echo "Checking links to config directories and files..."

if [ ! -e /opt/seafile/seafile-server-latest ]
then
    ln -s ${SEAFILE_PATH} /opt/seafile/seafile-server-latest
fi

if [ ! -e /opt/seafile/ccnet ]
then
    ln -s /seafile/ccnet /opt/seafile/ccnet
fi

if [ ! -e /opt/seafile/conf ]
then
    ln -s /seafile/conf /opt/seafile/conf
fi

if [ ! -e /opt/seafile/logs ]
then
    ln -s /var/log/seafile /opt/seafile/logs
fi

if [ ! -e /opt/seafile/seahub.db ]
then
    ln -s /seafile/seahub.db /opt/seafile/seahub.db
fi

if [ ! -e /opt/seafile/seahub-data ]
then
    ln -s /seafile/seahub-data /opt/seafile/seahub-data
fi

if [ ! -e /opt/seafile/seafile-server-latest/seahub/media/custom ]
then
    ln -s /seafile/data/custom /opt/seafile/seafile-server-latest/seahub/media/custom
fi

echo "All setup, ready to start..."
