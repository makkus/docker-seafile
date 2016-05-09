#
# Nginx Dockerfile
#
# https://github.com/dockerfile/nginx
#

# Pull base image.
FROM phusion/baseimage:0.9.16

ADD certs /etc/certs


# Install Nginx.
RUN \
  echo "deb http://archive.ubuntu.com/ubuntu trusty main universe multiverse restricted" > /etc/apt/sources.list && \
  echo "deb http://archive.ubuntu.com/ubuntu trusty-security main universe multiverse restricted" >> /etc/apt/sources.list && \
  apt-get update && \
  apt-get install -y wget apache2 libapache2-mod-fastcgi zile python-flup
	

ADD default-ssl.conf /etc/apache2/sites-available/default-ssl.conf
ADD 000-default.conf /etc/apache2/sites-available/000-default.conf

#RUN shib-keygen -h marcus.binsteiner.sitstf.auckland.ac.nz

RUN \
  a2enmod rewrite && \
	a2enmod fastcgi && \
	a2enmod proxy && \
	a2enmod proxy_http && \
	a2enmod ssl && \
	a2ensite default-ssl
	

RUN echo "FastCGIExternalServer /var/www/seahub.fcgi -host seafile:8000" >> /etc/apache2/apache2.conf
RUN echo "FastCGIExternalServer /var/www/seafdav.fcgi -host seafile:8080" >> /etc/apache2/apache2.conf

ADD run.sh /run.sh
RUN chmod 755 /run.sh

# Define working directory.
WORKDIR /etc/apache2

# Define default command.
#CMD ["/bin/bash"]
#CMD ["/usr/sbin/apache2 -D FOREGROUND"] 
CMD ["/run.sh"]

# Expose ports.
EXPOSE 80
EXPOSE 443

# Clean up APT when done.dd
#RUN apt-get clean && rm -rf /var/lib/apt/lists/* 

#RUN if [ ! -z ${SEAFILE_ENV_SEAFILE_SITE_ROOT} ]; then sed -i -e "s/^\s*location \/seafile/    location \/${SEAFILE_ENV_SEAFILE_SITE_ROOT}/" /etc/nginx/sites-enabled/default; else sed -i -e "s/^\s*location \/seafile/    location \//" /etc/nginx/sites-enabled/default; fi
