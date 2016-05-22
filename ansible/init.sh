#!/bin/bash

ansible-playbook container.yml -t container:startup-scripts

chmod +x /app_init.sh

/app_init.sh
