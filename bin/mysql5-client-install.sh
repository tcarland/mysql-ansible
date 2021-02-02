#!/bin/bash
#  Install wrapper script to sync configs only
#
tdh_path=$(dirname "$(readlink -f "$0")")

group="clients"
tag="client5"

# -------

( $tdh_path/mysqld-install.sh --group $group --tags $tag $@ )

exit $?
