#!/usr/bin/env bash
#
env="$1"


if [ -z "$env" ]; then
    echo "Usage: $0 <env>"
    echo " where 'env' is the ansible inventory name"
    exit 0
fi

( ansible-playbook -i inventory/$env/hosts mysqld-status.yml )

exit $?
