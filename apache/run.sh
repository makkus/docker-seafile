#!/bin/bash

#if [ "$ALLOW_OVERRIDE" = "**False**" ]; then
#		unset ALLOW_OVERRIDE
#else
#		sed -i "s/AllowOverride None/AllowOverride All/g" /etc/apache2/apache2.conf
#		a2enm rewrite
#fi

# fix hostname in /etc/apache2/sites-available/
sed -i -e "s/^\s*ServerName.*/         ServerName ${SEAFILE_ENV_SEAFILE_HOSTNAME}/" /etc/apache2/sites-available/000-default.conf
sed -i -e "s/^\s*Redirect.*/         Redirect permanent \/ https:\/\/${SEAFILE_ENV_SEAFILE_HOSTNAME}\//" /etc/apache2/sites-available/000-default.conf
sed -i -e "s/^\s*ServerName.*/         ServerName ${SEAFILE_ENV_SEAFILE_HOSTNAME}/" /etc/apache2/sites-available/default-ssl.conf

if [ ! -z ${SEAFILE_ENV_SEAFILE_SITE_ROOT} ]; then sed -i -e "s/^RewriteRule \^(\.\*)/RewriteRule ^\/(${SEAFILE_ENV_SEAFILE_SITE_ROOT}.*)/" /etc/apaches/sites-enabled/default-ssl.conf; fi

/etc/init.d/shibd restart

source /etc/apache2/envvars
tail -F /var/log/apache2/* &
exec apache2 -D FOREGROUND
