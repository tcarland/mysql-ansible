mysql-ansible
=============

Ansible playbook for installing MySQL Community Edition on a pair of
hosts in a master-slave replication configuration.

The *prereqs* role installs the yum packages and configuration, followed
by the *mysqld* role which configures accounts and master-slave replication.

## Inventory Configuration

Inventory follows the ./inventory/$env/hosts convention with the `hosts`
file defined as:
```
[master]
hostname01

[slave]
hostname02

[mysqld:children]
master
slave

[clients]
hostname01
hostname02
client01
client02
```

Variables defined per environment are provided in the inventory file
`inventory/$env/group_vars/all/vars`. Note that the two hostname
variables should be defined as the matching Fully-Qualified Domain Name (fqdn)
or there will be trouble with MySQL permissions (Grant statements).
```
---
mysql_port: '3306'
mysql_repl_user: 'repluser'

# use fully qualified domain names
mysql_master_hostname: 'hostname01.project.internal'
mysql_slave_hostname: 'hostname02.project.internal`

mysql_master_hosts:
  - '{{ mysql_master_hostname }}'
  - '{{ mysql_slave_hostname }}'

mysql_bind_address: '0.0.0.0'

mysql_binlog_format: 'MIXED'
mysql_max_connections: '350'

mysql_data_dir: '/var/lib/mysql'
mysql_tmp_dir: '/tmp/mysql'
```

MySQL passwords are provided by the inventory vault file
`inventory/$env/group_vars/all/vault` with passwords defined for the root
and replication accounts.
```
---
mysql_root_password: 'myrootpw'
mysql_repl_password: 'myreplpw'
```

# MySQL Clients 

The inventory also supports a `clients` group for installing just the
mysql client libraries and the MySQL JDBC Connector.  The wrapper
script `mysql-client-install.sh` runs the install yaml with the
supported `client5` tag to limit the playbook run as client install only.

The *server5* and *client5* tags specifically refer to and install MySQL
verion 5.7.x and is the default for an install.

Note that the *client* role performs a manual install of the MySQL Java
Connector.  First, not all versions of the mysql connector are equal
and there are compatibility issues with different versions. The
version chosen (currently 5.1.46) has been tested with a large number of
environments and works well with both older MySQL 5.5 and the currently
deploying MySQL 5.7.  The latter is the preferred version of MySQL most
compatible with the larger (hadoop) application ecosystem and is still the 
best version for compatibility across many projects (namely Apache Hive).

The connector is installed manually, primarily to avoid pulling in RPM
dependencies that may not be desired by this playbook (namely a JDK). 
Notably, this playbook specifically does NOT install the Java JDK since 
it cannot predict the required JDK version.

MySQL 8.0 support has been added via the *server8* and *client8* tags.
```
env="alderwest1"
./bin/mysqld-install.sh -T server8,client8 run $env
```

## Mysql Distribution and Version info.

The MySQL community repository configuration and related package version 
is defined by the defaults file *roles/common/defaults/main.yml*. This 
requires regular adjustments as new releases are made.