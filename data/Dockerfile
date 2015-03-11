FROM phusion/baseimage:0.9.16

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

ADD prepare-volumes.sh /tmp/prepare-volumes.sh
RUN /tmp/prepare-volumes.sh

VOLUME /var/www
VOLUME /opt/seafile
VOLUME /var/lib/seafile-data
VOLUME /var/lib/mysql
VOLUME /backup

# Clean up APT when done.dd
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
