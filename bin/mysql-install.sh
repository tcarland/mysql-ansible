#!/usr/bin/env bash
#
#
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
            tdh_version
            exit 1
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

echo "Running Ansible Playbook:  mysql-install.yml"
echo ""
echo "( ansible-playbook -i inventory/$env/hosts mysql-install.yml )"

if [ $dryrun -eq 0 ]; then
    ( ansible-playbook -i inventory/$env/hosts mysql-install.yml )
    rt=$?
fi

exit $rt
