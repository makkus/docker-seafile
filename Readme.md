This project is about creating a set of Docker containers to run a [Seafile](http://seafile.com/en/home/) service.

The setup consists of a data-only container, which encapsulates all volumes for all containers in order to make the configuration of the related data storage easier. 

## Features

 - [MariaDB](https://mariadb.org/) as backend database
 - [nginx](http://nginx.org) as web-server frontend
   - install script creates self-signed certificates if not present
   - preconfigured to only allow https
   - preconfigured webdav
 - configurable cron-job for garbage collection
 - configurable cron-job for backup

## Documentation

 - [Configure/Install](https://github.com/makkus/docker-seafile/blob/master/Install.md)
 - [Overview](https://github.com/makkus/docker-seafile/blob/master/Overview.md)

## Quickstart

For this quickstart to work, you need to add the line:

    127.0.0.1     localhost.home
   
to the file */etc/hosts*. Use **localhost.home** as the hostname when asked, and answer the rest of the questions according to [the config section here](https://github.com/makkus/docker-seafile/blob/master/Install.md#first-run).

    git clone https://github.com/makkus/docker-seafile.git
    cd docker-seafile
    sudo ./first-time-setup.sh
    ...
    ...
    <answer all the questions>
    ...
    ...
    firefox https://localhost.home/seafile
    (accept insecure host cert when browser warns)

## TODO

 - write wrapper script to update seafile 
 - scripts to restore from backup
 - more configuration options upfront
 - configurable cron jobs
 - configurable backup scripts
 - remove old backups
 - revisit/simplify services/runit start files
 - configurable UIDs/GIDs for volumes

## Thanks

 - Github user 'JensErat', for pointing me in the right direction with his [docker-seafile](https://github.com/JensErat/docker-seafile) repo
