# Requirements

 - [Docker](https://docs.docker.com/installation/), v 1.4+
 - [Docker compose](http://docs.docker.com/compose/install/), v1.1+

## Installing docker on Ubuntu

We want to use the docker packages from dockers repository, the ones that come with Ubuntu are usually a bit outdated:

    sudo apt-get purge docker.io
    curl -s https://get.docker.io/ubuntu/ | sudo sh
    sudo apt-get update
    sudo apt-get install lxc-docker
    
## Installing docker-compose on Ubuntu

As per instructions from the [docker-compose manual](http://docs.docker.com/compose/install/):

    curl -L https://github.com/docker/compose/releases/download/1.1.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose

# Setup

Because of the, well, lets just say 'unusual' setup procedure of seafile, it's hard to provide a docker container that does not require manual intervention. That's why there is a script that needs to run at first start, which will ask for some details, in addition to the config files.

## Checkout

Check out this repository, then enter the ```docker-seafile``` folder:

    git clone https://github.com/makkus/docker-seafile.git
	cd docker-seafile

## Initial config

### Choose a webserver:

I prepared templates for the user of both *nginx* and *apache*. For the latter there is also the possibility to use Shibboleth for authentication. Check out the provided *docker-compose.yml.example.<xxx>* files for details, and copy the one that suits you as **docker-compose.yml**

### Using seafile professional

There is an option to use the professional version of seafile instead of the community one.

To use that, copy the **docker-compose.yml.example.pro.nginx** example file as **docker-compose.yml**, then check your license email for your download link, which will have a token at the end of it ( https://cloud.seafile.de/d/TOKEN/ ). Take not of that, and put it as TOKEN value in the *seafile* section. Also make sure to specify the right seafile-pro version.


### Create initial *docker-compose.yml*

The main config file is named 'docker-compose.yml'. You can create a template by copying one of the example files:

    cp docker-compose.yml.example.nginx docker-compose.yml


In the editor of your choice, you can control the setup by changing some of the following sections:

### Volumes

All volumes are defined in the *data* container. You don't have to change any of those, in which case all the data will be stored in the docker data container itself:

    volumes:
     - /etc/timezone:/etc/timezone:ro
     - /etc/localtime:/etc/localtime:ro
     - /var/lib/mysql
     - /var/lib/seafile-data
     - /opt/seafile
     - /backup

Or, you could map some or all of the volumes to directories on your host system, like so:

    volumes:
     - /etc/timezone:/etc/timezone:ro
     - /etc/localtime:/etc/localtime:ro
     - /home/markus/docker/seafile/db:/var/lib/mysql
     - /home/markus/docker/seafile/seafile-data:/var/lib/seafile-data
     - /home/markus/docker/seafile/seafile:/opt/seafile
     - /home/markus/docker/seafile/backup:/backup
     
In that case you need to make sure for those directories to have the right permissions. The default uid/gid for access to those directories is 1000 (the default for the first user on an Ubuntu system). You can change this in the ids.lst file if you need to, then adapt the permissions on those directories, e.g.:

    sudo chown -R 1001:1001 <db_dir>
    sudo chown -R 2000:2000 <data_dir> <seafile_dir> <backup_dir>
    

### Environment variables

**Note**: because of problems with the *env_file* feature of *docker-compose*, variables are configured in the docker-compose.yml file for now. That is supposed to change once I figured out what the problem is.

#### db:
	
 - **MARIADB_PASS**: the password for the *admin* user on the MariaDB container

#### seafile:

 - **SEAFILE_VERSION**: the version of seafile you want
 - **SEAFILE_DB_USER**: the username of the mariadb user to manage the seafile databases
 - **SEAFILE_DB_PASSWORD**: the password of the mariadb user to manage the seafile databases
 - **SEAFILE_HOSTNAME**: the hostname under which this seafile installation will be accessible, because of some internal seafile requirement, this either needs to be an ip address or a hostname with at last a domain name (basically, the string you provide needs to have a '.' in it, if you only want to test, just use something like: *boxname.home* , be aware you'll need this later in the manual seafile setup process, also, you'll need to add an entry into your /etc/hosts file if you do that, otherwise file up-/downloads won't work)
 - **SEAFILE_SITE_ROOT**: the path in the url under which seafile should be accessible (e.g. https://host.name.com/path). Use an empty string if you want Seafile to be accessible via the domain name.
 - **SEAFILE_SITE_TITLE**: the title of this seafile installation that will be displayed on the webpage, don't use fancy characters in there if possible, I'm not sure what the rules are, but sometimes the seafile install script rejects titles.
 - **ENABLE_BACKUP**: True or False, whether to automatically backup the seafile app data, the config, the database and the files stored in seafile
 - **ENABLE_GARBAGE_COLLECTION**: True or False, whether to run the garbage collection regularly (3am in the morning, every day). When garbage collection is running, seafile is shut down and therefore unavailable until it is finished.

### Additional settings

If you want to configure additional settings in *seahub_settings.py* (as per: http://manual.seafile.com/config/seahub_settings_py.html ), you can create/edit a file named *seahub_settings_template.py* in the project root folder. If it exists, the *first-time-setup.sh* script will copy its content to *seahub_settings.py* during the setup process. Check out the *seahub_settings_template.py.example* file provided.

### Shibboleth configuration

If using shibboleth, there are some required settings for *seahub_settings.py* to be configured. Check out *seahub_settings_template.py.example.apache_shibboleth* for details. You also need to create certificates and add a few files as volumes:

    volumes:
      - /data/seafile/shib/sp-cert.pem:/etc/shibboleth/sp-cert.pem
      - /data/seafile/shib/sp-key.pem:/etc/shibboleth/sp-key.pem
      - /data/seafile/shib/shibboleth2.xml:/etc/shibboleth/shibboleth2.xml
      - /data/seafile/shib/tuakiri-test-metadata-cert.pem:/etc/shibboleth/tuakiri-test-metadata-cert.pem
      - /data/seafile/shib/attribute-map.xml:/etc/shibboleth/attribute-map.xml

Check out *docker-compose.yml.example.apache_shibboleth* for a working example.

### Host certificate (optional)

If you have a host certificate for the server you intend to run, place it and the associated key in the *<selected_webserver_config>/certs* folder and rename the files to:

    cacert.pem
	privkey.pem

## First run

Execute the *first-time-setup.sh* script. This script will delete all potentially existing containers and their associated volumes, so be careful. It won't delete any local folders that are potentially mapped to volumes though. If you want to start from scratch, you'll need to delete those manually.

Anyway, run:

    sudo ./first-time-setup.sh

If no certificate is in the *<selected_webserver_config>/certs* folder, a self-signed one will be created. Answer the questions asked, the only vaguely important one is the "Common name", where you will have to enter your host name for the service. 

Now it will take a while for all the requirements and container-related stuff to be downloaded and built. Once that is done, the containers will be started, the database tables will be created, and the seafile setup process will be kicked off. Check out the Seafile documentation for more details [here](http://manual.seafile.com/deploy/using_mysql.html).

As I said before, the seafile installation process is unusual, and not really well suited for automated setup. I wrote an *expect* script to answer the following questions in the following way:

### [ server name ]

The name of the server that is displayed on the client. **SEAFILE_SITE_TITLE** from docker-compose.yml

### [ This server's ip or domain ]

This will be set to the **SEAFILE_HOSTNAME** environment variable in the docker-compose.yml file above, as well as the common name in your host certificate. For some reason Seafile requires the hostname to include a domain name, or you can use an ip address.

### ccnet server port

Using the default, 10001.

### seafile data

Again, leaving the default. But that is irrelevant, since a script will be run later to move that folder to be under /var/lib/seafile-data in the container, in order to make container data management better configurable. If it was left under **/opt/seafile**, it would not be easily possible to have map the application and data side of seafile to different (possibly remote) folders.

### seafile server port

Using the default, 12001

### seafile fileserver

Using the default, 8082

### Database configuration

A script already prepared the seafile database user & databases at this stage, so all we need to do is provide the installer with the right details:

#### Choose the way to initialize the seafile databases

Choosing **[2]**, 'Use existing ccnet/seafile/seahub' databases

#### Host of the mysql server

Using "db" (without quotes). That is the hostname within the docker network for the Mariadb container.

#### Port of the mysql server

Using the default, 3306.

#### mysql user for seafile

Using whatever you used in the docker-compose.yml file under **SEAFILE_DB_USER**.

#### password for mysql user

Using whatever you used in the docker-compose.yml file under **SEAFILE_DB_PASSWORD**

#### existing database name for ccnet

Using 'ccnet' (without quotes).

#### existing database name for seafile

Using 'seafile' (without quotes)

#### existing database name for seahub

Using 'seahub' (without quotes)

### Finishing first part of setup

Now the 'official' part of the 'manual' setup is finished. The seafile install script does it's thing now for a few seconds. 

## Seahub admin config

Now the service will be restarted, and we need to enter the admin credentials.

#### [ admin email ]

Your email address that you want to use for seafile administration.

#### [ admin password ]

The password for the admin user.

### Test your setup

Open a browser, and go to your new seafile webpage, the url should have been displayed by the setup script. If you don't have a proper ssl host certificate, you'll have to ignore your browsers security warning.

If your networking routes are not setup yet, you can also try to go to:

    https://localhost/<your_SEAFILE_SITE_ROOT>

But for that up-/download of files most likely won't work.
