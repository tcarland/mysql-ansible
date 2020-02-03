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
```

Variables defined per environment are provided in the inventory file
`inventory/$env/group_vars/all/vars`. Note that the two hostname
variables should be defined as the Fully-Qualified Domain Name (fqdn)
ou you will likely have trouble with MySQL permissions (Grant statements).
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

mysql_data_dir: '/var/lib/mysql'
```

MySQL passwords are provided by the vault file
`inventory/$env/group_vars/all/vault` with passwords defined for the root
and replication accounts.
```
---
mysql_root_password: 'myrootpw'
mysql_repl_password: 'myreplpw'
```
 
