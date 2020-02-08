#!/bin/bash
#  Install wrapper script to sync configs only
#
tdh_path=$(dirname "$(readlink -f "$0")")
tag="client"

# -------

( $tdh_path/mysqld-install.sh --group clients --tags $tag $@ )

exit $?
