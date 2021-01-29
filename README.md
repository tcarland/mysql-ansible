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

The inventory also supports a `clients` group for installing just the
mysql client libraries and the MySQL JDBC Connector.  The wrapper
script `mysql-client-install.sh` runs the install yaml with the
supported `client` tag to limit the playbook run to client only install.

Note that the client role installs a specific version of the MySQL Java
Connector manually.  First, not all versions of the mysql connector are equal
and there are absolutely compatibility issues with different versions. The
version chosen (currently 5.1.46) has been tested with a large number of
environments and works well with both older MySQL 5.5 and the currently
deploying MySQL 5.7.  The latter is the preferred version of MySQL most
compatible with the larger (hadoop) application ecosystem and is still the 
best version for compatability across many projects (namely Apache Hive).

The connector is installed manually, primarily to avoid pulling in RPM
dependencies that may not be desired by this playbook. Most importantly, 
we do NOT install the Java JDK from this playbook, which might also occur 
by trying use the system package repository.


- Attempt a secure install, acquiring pw from log
```
- name: Enable mysql
  systemd:
    name: mysqld
    state: restarted
    enabled: yes
- name: Get root password
  shell: "grep 'A temporary password is generated for root@localhost' /var/log/mysqld.log | awk -F ' ' '{print $(NF)}'"
  register: root_password
- name: Update root password
  command: mysql --user root --password={{ root_password.stdout }} --connect-expired-password --execute="ALTER USER 'root'@'localhost' IDENTIFIED BY '{{ mysql_root_password }}';"
- name: Create client users
  mysql_user:
    login_user: root
    login_password: "{{ mysql_root_password }}"
    name: "{{ item.name }}"
    password: "{{ item.password }}"
    priv: '*.*:ALL,GRANT'
    state: present
    host: '%'
  with_items:
    - "{{ mysql.users }}"
```