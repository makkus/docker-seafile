FROM phusion/baseimage:0.9.16

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

RUN useradd seafile -d /opt/seafile -s /bin/bash -u 2000
RUN mkdir /opt/seafile
RUN mkdir /var/lib/seafile-data
RUN chown -R seafile /opt/seafile
RUN chown -R seafile /var/lib/seafile-data

VOLUME /var/www

VOLUME /opt/seafile
VOLUME /var/lib/seafile-data

RUN mkdir /var/lib/mysql
VOLUME /var/lib/mysql

VOLUME /backup

# Clean up APT when done.dd
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
