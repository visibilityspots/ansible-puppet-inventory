ansible puppet inventory
------------------------

This repository is meant to share an ansible plugin which provides a dynamic ansible inventory based on your puppet environment through puppetdb.

### environments

In the environments directory you can find a puppetdb query for each environment you have (default development and production). Those files will be used by the puppetdb inventory script to create groups of hosts per puppet environment.

### puppetdb.sh

This is the actual script which will call the puppetdb api to dynamically lookup for the nodes in your puppet environments to be used in ansible.

### ansible

You should adapt the environments/files to your needs, rename the files to your puppet environments and adapt them so they reflect your catalog-environments. Then copy them over to your ansible root directory:

```bash
  $ sudo cp -R environments /etc/ansible
```

There are different ways to configure your ansible environment to use this dynamic inventory script.

You could copy it over to /etc/ansible/hosts:

```bash
  $ sudo cp puppetdb.sh /etc/ansible/hosts
```
Or you could use the -i inventory parameter:

```bash
  $ ansible -i puppetdb.sh
```
### examples

When replaced hosts file:

```bash
  $ ansible development -a 'whoami' --sudo -K --list-hosts
```

Using the --inventory option

```bash
  $ ansible development -i puppetdb.sh -a 'whoami' --sudo -K --list-hosts
```

### source

[codecentric.de](https://blog.codecentric.de/en/2014/09/use-ansible-remote-executor-puppet-environment/)
