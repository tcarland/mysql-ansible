#!/usr/bin/env bash
#
#
PNAME=${0##*\/}
MYSQL_ANSIBLE_VERSION="v21.01"

playbook="mysqld-install.yml"
action=
env=

# -------------------

usage="
Usage: $PNAME <action> <env>
  <action> : any action other than 'run' is a 'dryrun'
  <env>    : is the ansible inventory name (under ./inventory)
"

version="$PNAME (mysql-ansible) $MYSQL_ANSIBLE_VERSION"

# -------------------

# MAIN
#
rt=0
group=
dryrun=1
verbose=0

while [ $# -gt 0 ]; do
    case "$1" in
        -g|--group)
            group="$2"
            shift
            ;;
        'help'|-h|--help)
            echo "$usage"
            exit 0
            ;;
        -T|--tags)
            tags="$2"
            shift
            ;;
        -v|--verbose)
            verbose=1
            ;;
        'version'|-V|--version)
            echo "$version"
            exit 0
            ;;
        *)
            action="${1,,}"
            env="$2"
            shift $#
            ;;
    esac
    shift
done

if [ -z "$action" ] || [ -z "$env" ]; then
    echo "Error: Missing arguments..."
    echo "$usage"
    exit 1
fi

if [[ $action == "run" ]]; then
    dryrun=0
fi

echo "Running Ansible Playbook: '$playbook'"
echo ""

cmd="ansible-playbook -i inventory/$env/hosts"

if [ $verbose -eq 1 ]; then
    cmd="$cmd -vvv"
fi

if [ -n "$group" ]; then
    cmd="$cmd -l $group"
fi

if [ -n "$tags" ]; then
    cmd="$cmd --tags $tags"
fi

cmd="$cmd $playbook"

echo "( $cmd )"
if [ $dryrun -eq 0 ]; then
    ( $cmd )
    rt=$?
fi

exit $rt
