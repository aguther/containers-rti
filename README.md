# containers-rti
Repository to test RTI DDS with container technologies (docker, kubernetes).

## Environment
Vagrant can be used to deploy the necessary virtual machines.

In the default configuration you will get 3 VMs where the first is in the master group and the other two in the nodes group:

| Host         | Groups           | Private IP     |
|:------------:|:----------------:|:--------------:|
| centos-7-1   | centos<br>master | 172.30.0.11/24 |
| centos-7-2   | centos<br>nodes  | 172.30.0.12/24 |
| centos-7-3   | centos<br>nodes  | 172.30.0.13/24 |

#### Initialization
Thanks to vagrant the deployment of the virtual machines is really easy. The configuration can be found in the file `Vagrantfile`. It's possible to change the number of virtual machines and the playbook used during provisioning via environment variables (see below).

The virtual machines can be deploying with the following commands:
```bash
# optional, default = 3
export instance_count=4
# optional, default = deploy-docker-swarm.yml
export ansible_playbook=deploy-kubernetes.yml
vagrant up
```

#### Execution of additional playbooks after provisioning
```bash
vagrant ssh -c "cd /vagrant; ansible-playbook -i /tmp/vagrant-ansible/inventory/vagrant_ansible_local_inventory <playbook>"
```

#### Shutdown
```bash
vagrant halt
```

#### Destroy
```bash
vagrant destroy -f
```

## Docker - CentOS
In this scenario the rti-perftest example will be executed on single hosts with Docker 1.10 installed which is available in the extras-repository.
Weave-Net is used to connect the containers on the different hosts.

### Start
```bash
export ansible_playbook=deploy-docker.yml
vagrant destroy -f
vagrant up
vagrant ssh -c "cd /vagrant; ansible-playbook -i /tmp/vagrant-ansible/inventory/vagrant_ansible_local_inventory rti-perftest-docker-start.yml"
exit
```

### Stop
```bash
vagrant ssh -c "cd /vagrant; ansible-playbook -i /tmp/vagrant-ansible/inventory/vagrant_ansible_local_inventory rti-perftest-docker-stop.yml"
exit
```

### Monitoring
Monitoring can be done using the tool cockpit which can be reached on the address `http://<host>:9090`.


## Docker - CentOS - Swarm Mode
In this scenario the rti-perftest example will be executed on hosts with Docker 1.10 which is available in the extras-repository and additionally configured as a swarm.
Weave-Net is used to connect the containers on the different hosts.

The difference to the former scenario is that it's not predefined on which host the containers are executed, just the number.

### Start
```bash
export ansible_playbook=deploy-docker-swarm.yml
vagrant destroy -f
vagrant up
vagrant ssh -c "cd /vagrant; ansible-playbook -i /tmp/vagrant-ansible/inventory/vagrant_ansible_local_inventory rti-perftest-docker-swarm-start.yml"
exit
```

### Stop
```bash
vagrant ssh -c "cd /vagrant; ansible-playbook -i /tmp/vagrant-ansible/inventory/vagrant_ansible_local_inventory rti-perftest-docker-swarm-stop.yml"
exit
```

### Monitoring
Monitoring can be done using the tool cockpit which can be reached on the address `http://<host>:9090`. Cockpit has no support for Docker Swarm therefore every single host has to be monitored.

If you want to monitor using Weave-Scope you can enter the following command to deploy it:
```bash
vagrant ssh -c "cd /vagrant; ansible -i /tmp/vagrant-ansible/inventory/vagrant_ansible_local_inventory centos -a \"scope launch\""
exit
```

### Remark
When operating with Docker Swarm before 1.12 the commands need to be prefixed with `docker -H tcp://<swarm manager>:2400 <command> <arguments>`.

Example(s):
```bash
vagrant ssh
docker -H tcp://localhost:2400 info
docker -H tcp://localhost:2400 ps
exit
```


## Kubernetes - CentOS
In this scenario the rti-perftest example will be executed on a kubernetes cluster 1.3 which is available in the extras-repository.
Weave-Net is used to connect the containers on the different hosts.

### Start
```bash
export ansible_playbook=deploy-kubernetes.yml
vagrant destroy -f
vagrant up
vagrant ssh -c "cd /vagrant; ansible-playbook -i /tmp/vagrant-ansible/inventory/vagrant_ansible_local_inventory rti-perftest-kubernetes-start.yml"
exit
```

### Stop
```bash
vagrant ssh -c "cd /vagrant; ansible-playbook -i /tmp/vagrant-ansible/inventory/vagrant_ansible_local_inventory rti-perftest-kubernetes-stop.yml"
exit
```

### Monitoring
Monitoring can be done using the tool cockpit which can be reached on the address `http://<host>:9090`. It also supports Kubernetes and can be reached with the tab 'Cluster'.


## Links
-   [Vagrant](http://www.vagrantup.com)
-   [Docker](http://www.docker.io)
-   [Kubernetes](http://www.kubernetes.io)
-   [Weave-Net](https://www.weave.works/products/weave-net/)
-   [Weave-Scope](https://www.weave.works/products/weave-scope/)
-   [Introducing docker-latest for RHEL 7 and RHEL Atomic Host](https://access.redhat.com/articles/2317361)
-   [Installing Kubernetes Cluster with 3 minions on CentOS 7 to manage pods and services](http://severalnines.com/blog/installing-kubernetes-cluster-minions-centos7-manage-pods-services)
