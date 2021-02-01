#!/usr/bin/env bash
#
#
PNAME=${0##*\/}
MYSQL_ANSIBLE_VERSION="v21.02"

playbook="mysqld-install.yml"
tags="server5,client5"
action=
env=

# -------------------

usage="
Wrapper script to the ansible-playbook 'mysqld-install' for 
a given environment. By defaultm this installs MySQL 5.7, but 
mysql 8.0 can be set by passing the 'server8,client8' 
tags to the playbook via the '--tags' option.

Synopsis:
  $PNAME <action> <env>

Options:
  -g|--group       : Set a host 'limit' group for the run.
  -h|--help        : Show usage info and exit.
  -T|--tags <tags> : Set tags to control install version. 
  -v|--verbose     : Set increased verbosity in ansible.
  -V|--version     : Show version info and exit.

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
