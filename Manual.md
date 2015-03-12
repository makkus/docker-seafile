# Users

The services don't use root to run (except ), but non-privileged user accounts. Here is a list of users and groups, along with uids and gids (useful for preparing folders mapped to volumes):

| User     | default uid  |Default group (& gid) | Volumes                |
|==========|==============|======================|========================|
| mysql    | 1000         | mysql (1000)         | /var/lib/mysql         |
|----------|--------------|----------------------|------------------------|
| seafile  | 1000         | seafile (1000)       | /opt/seafile           |
|          |	          |                      | /var/lib/seafile-data  |
|          |              |                      | /backup                |

In all likelyhood you wouldn't need to do that, but you can change the default uids/gids by changing the values in the file *ids.lst* before running the *first-time-setup.sh* script.

# Volumes

All volumes are inherited from a common data container. Data containers are considered good practice for Docker deployments, in order to keep data and applications separated. Usually we'd have one data container per service, but I thought that'd probably a bit overkill. Also, I like the idea of having all the data relating to seafile (config, dbs, seafile data) in one container.

Depending on your need you can just use the data container as is, or map one to all volumes to local/remote folders on the machine that runs the containers. 

## /var/lib/mysql

The (default) folder for MySQL/MariaDB, containing all the databases.

## /var/lib/seafile-data

The data users store on seafile. Stored in a git-like format.

## /opt/seafile

The seafile configuration, as well as all versions of seafile that were installed over the lifetime of this installation. Bit unusual, but that is due to the non-standard way Seafile has to be setup/configured. 

## /backup

The folder where the (automated, optional) backups are stored. Would make sense to mount that on a remote (nfs, samba, cloud) share. Contains three seperate folders for mysql dump, seafile config/app (using bup for backup), and an rsynced image of /var/lib/seafile-data.

# cron jobs

## Garbage collection

[Seafile garbage collection](http://manual.seafile.com/maintain/seafile_gc.html) has to be executed while seafile is offline (unless you use the pay-version). The wrapper script used here stops all services, executes the garbage collection, then restarts the services again.

You can kick off the garbage collection manually by executing:

    ./seafile-gc.sh

in the project root directory.

The garbage collection cron job is disabled by default, but can be configured by setting the *ENABLE_GARBAGE_COLLECTION* environment variable to 'True'.
The (default) schedule is to run the garbage collection every day, at 2.55am. When the garbage collection is executed, the seafile service will be unavailable until it is finished, so you have to decide if you can live with that or not. Executing it can save some disk-space, and usually it does not take long, but that depends on how much data was changed/deleted since the last time it was run.

To change the schedule of the garbage collection, you need to edit the file *seafile/garbage_collection_schedule.sh* **before** creating the containers.

## Backup

You can kick off backup manually by executing:

    ./seafile-backup.sh

in the project root directory.

By default, the backup cron job is disabled. It can be enabled by setting the *ENABLE_BACKUP* environment variable to true. The (default) schedule to execute the backup is 3.15am, this can be change by editing the file *seafile/backup_schedule.sh* **before** creating the containers.

The way the backup is done can be modified as well, in order to do that edit the file *seafile/backup.sh*, again **before** the containers are created. By default, three different steps are executed during backup:

### mysql dump

A dump of all relevant databases (ccnet, seafile, seahub) are created in the folder **/backup/seafile/db**, named with a timestamp.

### seafile application directory

The folder **/opt/seafile** contains configuration data, as well as the seafile application (several versions under **seafile-server-xxx**, the latest is linked to be **seafile-server-latest**). In order to preserver the configuration history, [bup](https://github.com/bup/bup) is used to create the backup under **/backup/seafile/application**.

### seafile data

Last, but most importantly, the seafile user data is backed up, using rsync, to **/backup/seafile/data**. Since Seafile uses a git-like format to store the libraries, data can't be read directly via filesystem tools from this folder.

If that is necessary, one could change the backup script and make an rsync from the webdav endpoint, or possibly setup fuse and use that.

## Connect to containers

In case of problems, you can manually connect to (running) containers, using *docker exec*, which works similar to ssh. For convenience, there are 3 wrapper scripts for each of the running containers:

    ./connect_db.sh
    ./connect_seafile.sh
    ./connect_nginx.sh

## Upgrade seafile

If you want to upgrade your seafile server, there is also a wrapper script:

    ./seafile-upgrade.sh <target_version>

This logs into the seafile container, stops the seafile service, downloads the updated package, extracts it and puts it into the right place (/opt/seafile). 

Because I could not be bothered to do all the string version matching stuff that would have been required, and also because I think it's safer, there is some manual work. The wrapper script will print out some help text as to what needs to be done. 
