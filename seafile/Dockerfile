FROM ubuntu:16.04
MAINTAINER Markus Binsteiner <makkus@gmail.com>

ENV UID=1000
ENV GID=1000

RUN groupadd -o -g ${GID} seafile
RUN useradd seafile -o -d /opt/seafile -s /bin/bash -u ${UID} -g ${GID}

# get an up-to-date package repo
RUN apt update

# bootstrap ansible
RUN apt install -y python-setuptools python-dev libffi-dev libssl-dev git build-essential
RUN easy_install pip
RUN pip2 install ansible

RUN mkdir -p /etc/ansible
RUN sh -c 'echo "[local]\n127.0.0.1   ansible_connection=local\n" |  tee /etc/ansible/hosts'

# dev tools
RUN apt install -y zile

# build deps
RUN apt install -y expect curl

RUN apt install -y wget python2.7 libpython2.7 python-setuptools python-imaging python-ldap
# option sqlite
RUN apt install sqlite3

ENV SEAFILE_VERSION=5.1.1

RUN mkdir -p /var/log/seafile
RUN mkdir /seafile

RUN mkdir -p /opt/seafile
RUN mkdir -p /seafile/data/custom

COPY setup-seafile.sqlite.sh /opt/seafile/setup-seafile.sqlite.sh
RUN chmod +x /opt/seafile/setup-seafile.sqlite.sh
COPY setup-seafile.sqlite.expect /opt/seafile/setup-seafile.sqlite.expect
RUN chmod +x /opt/seafile/setup-seafile.sqlite.expect

RUN chown -R seafile:seafile /var/log/seafile
RUN chown -R seafile:seafile /opt/seafile
RUN chown -R seafile:seafile /seafile

VOLUME /seafile
VOLUME /var/log/seafile

EXPOSE 8000

USER seafile
WORKDIR /opt/seafile
