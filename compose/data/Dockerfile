FROM phusion/baseimage:0.9.16

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

ADD ids.lst /tmp/ids.lst
ADD prepare-users-volumes.sh /tmp/prepare-users-volumes.sh
RUN /tmp/prepare-users-volumes.sh

ADD volume-permissions.sh /root/volume-permissions.sh

VOLUME /var/www
VOLUME /opt/seafile
VOLUME /var/lib/seafile-data
VOLUME /var/lib/mysql
VOLUME /backup

# Clean up APT when done.dd
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
