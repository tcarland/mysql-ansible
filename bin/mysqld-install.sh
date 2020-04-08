#!/usr/bin/env bash
#
#
PNAME=${0##*\/}

MYSQL_ANSIBLE_VERSION="0.4.0"
playbook="mysqld-install.yml"
action=
env=


usage()
{
    echo ""
    echo "Usage: $PNAME <action> <env>"
    echo "  <action> : any action other than 'run' is a 'dryrun'"
    echo "  <env>    : is the ansible inventory name."
    echo ""
}

version()
{
    echo ""
    echo "$PNAME (mysql-ansible) v$MYSQL_ANSIBLE_VERSION"
    echo ""
}


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
        -h|--help)
            usage
            exit 0
            ;;
        -T|--tags)
            tags="$2"
            shift
            ;;
        -v|--verbose)
            verbose=1
            ;;
        -V|--version)
            version
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
    usage
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
