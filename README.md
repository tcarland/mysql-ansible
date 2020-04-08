mysql-ansible
=============

  Ansible playbook for installing MySQL Community Edition 5.7 on a pair of
hosts in a master-slave replication configuration.

  The *prereqs* role installs the yum packages and configuration, followed
by the *mysql* role which configures accounts and master-slave replication.

  Inventory follows the ./inventory/$env/hosts convention with the `hosts`
file defined as:
```
[master]
hostname01

[slave]
hostname02

[mysql:children]
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

mysql_binlog_format: 'MIXED'

mysql_data_dir: '/var/lib/mysql'
mysql_tmp_dir: '/tmp/mysql'

mysql_connector: 'mysql-connector-java'
mysql_connector_name: '{{ mysql_connector }}-5.1.46'
mysql_connector_jarfile: '{{ mysql_connector_name }}-bin.jar'
mysql_connector_tarball: '{{ mysql_connector_name }}.tar.gz'

mysql_connector_path: '/usr/share/java'
mysql_connector_srcpath: '{{ mysql_tmp_dir }}/{{ mysql_connector_name }}'

mysql_connector_uri: 'https://dev.mysql.com/get/Downloads/Connector-J'
mysql_connector_url: '{{ mysql_connector_uri }}/{{ mysql_connector_tarball }}'
```


MySQL passwords are provided by the vault file
`inventory/$env/group_vars/all/vault` with passwords defined for the root
and replication accounts.
```
---
mysql_root_password: 'myrootpw'
mysql_repl_password: 'myreplpw'
```

The inventory also supports a `clients` group for installing just
the client libraries and the MySQL JDBC Connector.  The wrapper
script `mysql-client-install.sh` runs the install yaml with the
supported `client` tag to limit the playbook run to client only
install.
