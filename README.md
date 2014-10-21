README
------

This repository is meant to share my ansible plugin which provides a dynamic ansible inventory based on you puppet environment through puppetdb.

### environments

In the environments directory you can find a puppetdb query for each environment you have (default development and production). Those files will be used by the puppetdb inventory script to create groups of hosts per puppet environment.

### puppetdb.sh

This is the actual script wich will call the puppetdb api to dynamically lookup for the nodes in your environment which you can use in ansible

### ansible

There are different ways to configure your ansible environment to use this dynamic inventory script

You could copy it over to /etc/ansible/hosts:
```bash
  $ cp puppetdb.sh /etc/ansible/hosts
```
Or you could use the -i inventory parameter:
```bash
  $ ansible -i puppetdb.sh
```
### examples
```bash
  $ ansible development -i puppetdb.sh -a 'whoami' --sudo -K
```
