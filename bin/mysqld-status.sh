#!/usr/bin/env bash
#
env="$1"
usage="
Displays MySQL Master/Slave Replication status.

Usage: $0 <env_name>
 where 'env_name' is the ansible inventory name under '.inventory'
"

if [ -z "$env" ]; then
    echo "$usage"
    exit 0
fi

( ansible-playbook -i inventory/$env/hosts mysqld-status.yml )

exit $?
