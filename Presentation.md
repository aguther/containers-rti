<!--
	$theme: gaia
    template: invert
-->

Lunch & Learn
===

###### Vagrant, Ansible, Docker, Kubernetes
<!-- *footer: Andreas Guther - github.com/aguther -->

---
# Vagrant

---
> Vagrant is an open-source software product for building and maintaining portable virtual development environments.
<!-- *footer: wikipedia.org -->

---
# How to use?

---
# Installation
- Windows, Linux or macOS
- Administrative Account
- VirtualBox
- Vagrant

---

# Get started
```bash
$ vagrant init bento/centos-7.3
$ vagrant up
```

---
# Demo

---
# Multi-Machine
```ruby
Vagrant.configure("2") do |config|

  config.vm.define "web" do |web|
    web.vm.box = "apache"
  end

  config.vm.define "db" do |db|
    db.vm.box = "mysql"
  end

end
```

---
# Demo

---
# Ansible

---
> Ansible is an open-source automation engine that automates cloud provisioning, configuration management, and application deployment.
<!-- *footer: wikipedia.org -->

---
> **AUTOMATION FOR EVERYONE**
>
> Deploy apps. Manage systems. Crush complexity.
> Ansible helps you build a strong foundation for DevOps.
<!-- *footer: ansible.com -->

---
# How to use?

---
# Installation
- RHEL / CentOS with EPEL repository: `yum install ansible`
- Other platforms:
[docs.ansible.com](http://docs.ansible.com/ansible/intro_installation.html)

---
# Get started
- Inventory
- Command

---
# Inventory
Creation:
```bash
$ touch ./hosts
$ vim ./hosts
```
Content:
```
[centos]
centos-1
centos-2
centos-3

[centos:vars]
ansible_user=vagrant
ansible_ssh_password=vagrant
```

---
# Command
Get hostname:
```bash
$ ansible -i ./hosts all -a "hostname"
```

---
# Demo

---
# Playbooks

---
# Playbooks
- ...
- ...
- ...

---
# Demo

---
# Docker

---
# Dockerfile
```
# define parent
FROM centos:7

# add RTI Perftest binary package
ADD https://[...] /rtiperftest.tar.gz

# extract archive
RUN tar xzf /rtiperftest.tar.gz

# define work directory and entrypoint
WORKDIR "[...]"
ENTRYPOINT ["[...]/perftest_cpp"]
```
Complete Dockerfile:
[https://github.com/aguther/rti-perftest](https://github.com/aguther/rti-perftest/blob/master/Dockerfile)

---
# Demo

---
# Network Types

---


---
# Kubernetes
