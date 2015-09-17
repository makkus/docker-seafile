This project is about creating a set of Docker containers to run a [Seafile](http://seafile.com/en/home/) service.

Note: only seems to be working on a Linux host at the moment. If you are a Mac user and get it to work, please do tell me.

The setup consists of a data-only container, which encapsulates all volumes for all containers in order to make the configuration of the related data storage easier. 

## Features

 - [MariaDB](https://mariadb.org/) as backend database
 - [nginx](http://nginx.org) as web-server frontend
   - install script creates self-signed certificates if not present
   - preconfigured to only allow https
   - preconfigured webdav
 - configurable cron-job for garbage collection
 - configurable cron-job for backup
 - option to use either the community version, or the professional one (although the latter only has basic support at the moment)

## Documentation

 - [Configure/Install](https://github.com/makkus/docker-seafile/blob/master/Install.md)
 - [Manual](https://github.com/makkus/docker-seafile/blob/master/Manual.md)

## Quickstart

For this quickstart to work, you need to have [Docker, v 1.4+](https://docs.docker.com/installation/) and [Docker compose, v 1.1+](http://docs.docker.com/compose/install/) installed. Also, you need to add the line:

    127.0.0.1     localhost.home
   
to the file */etc/hosts*. Use **localhost.home** as the hostname when asked, and answer the rest of the questions according to [the config section here](https://github.com/makkus/docker-seafile/blob/master/Install.md#first-run).

    git clone https://github.com/makkus/docker-seafile.git
    cd docker-seafile
    sudo ./first-time-setup.sh
    ...
    ...
    <enter admin email and password>
    ...
    ...
    firefox https://localhost.home/seafile
    (accept insecure host cert when browser warns)

## TODO
 - fix backup & upgrade scripts
 - scripts to restore from backup
 - more configuration options upfront
 - configurable cron jobs
 - configurable backup scripts
 - remove old backups
 - revisit/simplify services/runit start files
 - add memcached
 - better support for pro version

## Thanks

 - Github user 'JensErat', for pointing me in the right direction with his [docker-seafile](https://github.com/JensErat/docker-seafile) repo
