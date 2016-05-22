FROM phusion/baseimage:0.9.18
MAINTAINER Markus Binsteiner <makkus@gmail.com>

ENV PUID=1000
ENV PGID=1000

ENV SEAFILE_VERSION=5.1.1

# get an up-to-date package repo
RUN apt update

# bootstrap ansible
RUN apt install -y python-setuptools python-dev libffi-dev libssl-dev git build-essential
RUN easy_install pip
RUN pip2 install -U setuptools
RUN pip2 install -U ansible

RUN mkdir -p /etc/ansible
RUN sh -c 'echo "[local]\n127.0.0.1   ansible_connection=local\n" |  tee /etc/ansible/hosts'

COPY app_init.sh /app_init.sh

COPY ansible /ansible
RUN chmod +x /ansible/init.sh
RUN chmod +x /ansible/install.sh

COPY default /ansible/install/default

RUN /ansible/install.sh

VOLUME /seafile
VOLUME /var/log/seafile

EXPOSE 8000
EXPOSE 80
EXPOSE 443
EXPOSE 2015

WORKDIR /ansible
CMD ["/ansible/init.sh"]
