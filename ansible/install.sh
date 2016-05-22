#!/bin/bash

rsync -a /ansible/install/default/files/ /

cd /ansible/

ansible-playbook container.yml --extra-vars "@/ansible/install/default/vars.yml" -t container:executables
ansible-playbook container.yml --extra-vars "@/ansible/install/default/vars.yml" -t container:directories
ansible-playbook container.yml --extra-vars "@/ansible/install/default/vars.yml" -t container:groups
ansible-playbook container.yml --extra-vars "@/ansible/install/default/vars.yml" -t container:users
ansible-playbook container.yml --extra-vars "@/ansible/install/default/vars.yml" -t container:dev
ansible-playbook container.yml --extra-vars "@/ansible/install/default/vars.yml" -t container:build
ansible-playbook container.yml --extra-vars "@/ansible/install/default/vars.yml" -t container:dependencies
ansible-playbook container.yml --extra-vars "@/ansible/install/default/vars.yml" -t container:directory-attributes
