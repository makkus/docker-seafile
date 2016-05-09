#!/bin/bash

docker exec -i -t dockerseafile_seafile_1 /sbin/setuser seafile /usr/local/bin/upgrade-seafile $1
