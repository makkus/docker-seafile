#
# Nginx Dockerfile
#
# https://github.com/dockerfile/nginx
#

# Pull base image.
FROM phusion/baseimage:0.9.16

# Install Nginx.
RUN \
  add-apt-repository -y ppa:nginx/stable && \
  apt-get update && \
  apt-get install -y nginx zile python-flup && \
  chown -R www-data:www-data /var/lib/nginx


ADD nginx.conf /etc/nginx/nginx.conf
ADD certs /etc/nginx/certs
ADD conf.d /etc/nginx/conf.d
ADD sites-enabled /etc/nginx/sites-enabled

# Define working directory.
WORKDIR /etc/nginx

# Define default command.
CMD ["nginx"]

# Expose ports.
EXPOSE 80
EXPOSE 443

# Clean up APT when done.dd
RUN apt-get clean && rm -rf /var/lib/apt/lists/* 

# fix hostname in /etc/nginx/sites-enabled/default
RUN sed -i -e "s/^\s*server_name.*/    server_name = ${SEAFILE_ENV_SEAFILE_HOSTNAME};/" /etc/nginx/sites-enabled/default
RUN if [ ! -z ${SEAFILE_ENV_SEAFILE_SITE_ROOT} ]; then sed -i -e "s/^\s*location \/seafile/    location \/${SEAFILE_ENV_SEAFILE_SITE_ROOT}/" /etc/nginx/sites-enabled/default; else sed -i -e "s/^\s*location \/seafile/    location \//" /etc/nginx/sites-enabled/default; fi
