#!/usr/bin/env bash
#
#
PNAME=${0##*\/}
MYSQL_ANSIBLE_VERSION="0.3.0"
playbook="mysqld-install.yml"
action=
env=


usage()
{
    echo ""
    echo "Usage: $PNAME <action> <env>"
    echo "  <action> any action other than 'run' is a 'dryrun'"
    echo "  <env>    is the ansible inventory name."
    echo ""
}

version()
    echo "mysql-ansible v${MYSQL_ANSIBLE_VERSION}"
}


# MAIN
#
rt=0
dryrun=1

while [ $# -gt 0 ]; do
    case "$1" in
        -T|--tags)
            tags="$2"
            shift
            ;;
        -V|--version)
            version
            exit 0
            ;;
        *)
            action="$1"
            env="$2"
            shift $#
            ;;
    esac
    shift
done

if [ -z "$action" ] || [ -z "$env" ]; then
    usage
    exit 1
fi

if [[ $action == "run" ]]; then
    dryrun=0
fi

echo "Running Ansible Playbook: '$playbook'"
echo ""
echo "( ansible-playbook -i inventory/$env/hosts $playbook )"

if [ $dryrun -eq 0 ]; then
    ( ansible-playbook -i inventory/$env/hosts $playbook )
    rt=$?
fi

exit $rt
