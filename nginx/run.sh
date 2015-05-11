#!/bin/bash

# fix hostname in /etc/nginx/sites-enabled/default
sed -i -e "s/^\s*server_name.*/    server_name = ${SEAFILE_ENV_SEAFILE_HOSTNAME};/" /etc/nginx/sites-enabled/default
if [ ! -z ${SEAFILE_ENV_SEAFILE_SITE_ROOT} ]; then sed -i -e "s/^\s*location \/seafile/    location \/${SEAFILE_ENV_SEAFILE_SITE_ROOT}/" /etc/nginx/sites-enabled/default; else \
		sed -i -e "s/^\s*location \/seafile/    location \//" /etc/nginx/sites-enabled/default; fi

nginx

