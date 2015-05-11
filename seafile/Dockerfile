FROM	phusion/baseimage:0.9.16
MAINTAINER	Markus Binsteiner <makkus@gmail.com>

CMD ["/sbin/my_init"]

# Seafile dependencies and system configuration
RUN apt-get update && apt-get install -y \
		python2.7 \
		python-setuptools \
		python-simplejson \
		python-imaging \
		sqlite3 \
		python-mysqldb \
		python-memcache \
		mysql-client \
		socat \
		zile \ 
		bup \
		expect \
		python-flup

RUN ulimit -n 30000

# script to download seafile
RUN mkdir -p /opt/scripts/
ADD setup-seafile.sh /usr/local/bin/setup-seafile
ADD setup-seafile.expect /usr/local/bin/setup-seafile.expect
RUN chmod 755 /usr/local/bin/setup-seafile
RUN chmod 755 /usr/local/bin/setup-seafile.expect
ADD upgrade-seafile.sh /usr/local/bin/upgrade-seafile
ADD create_db.sql /opt/scripts/create_db.sql
ADD garbage_collection.sh /opt/scripts/seafile-gc
ADD backup.sh /opt/scripts/seafile-backup
ADD custom /tmp/seafile-custom
# create seafile & backup user
ADD ids.lst /tmp/ids.lst
ADD prepare-user.sh /tmp/prepare-user.sh
RUN /tmp/prepare-user.sh

ADD backup_schedule.sh /etc/cron.d/backup_schedule.sh
ADD garbage_collection_schedule.sh /etc/cron.d/garbage_collection_schedule.sh

EXPOSE 10001 12001 8000 8080 8082

RUN mkdir -p /var/log/seafile
RUN chown -R seafile /var/log/seafile

# Seafile daemons
RUN mkdir -p /etc/service/seafile_services
ADD seafile_services.sh /etc/service/seafile_services/run
ADD seafile_services_stop.sh /etc/service/seafile_services/finish
RUN mkdir -p /etc/seafile/service/seafile /etc/seafile/service/seahub
ADD seafile.sh /etc/seafile/service/seafile/run
ADD seafile_stop.sh /etc/seafile/service/seafile/finish
ADD seahub.sh /etc/seafile/service/seahub/run
ADD seahub_stop.sh /etc/seafile/service/seahub/finish
RUN chown -R seafile /etc/seafile

# Clean up for smaller image
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /var/tmp/*
