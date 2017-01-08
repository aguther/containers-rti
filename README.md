# containers-rti
Repository to test RTI DDS with container technologies (docker, kubernetes).

## Environment

### Manual Deployment
The following describes the environment that was in mind for this example.

3 Hosts with the latest CentOS 7:

| Host       | IPv4            | DNS             | Default-Gateway |
|:----------:|:---------------:|:---------------:|:---------------:|
| centos-7-1 | 192.168.198.101 | 192.168.198.2   | 192.168.198.2   |
| centos-7-2 | 192.168.198.101 | 192.168.198.2   | 192.168.198.2   |
| centos-7-3 | 192.168.198.101 | 192.168.198.2   | 192.168.198.2   |

### Vagrant Deployment
Vagrant can be used to deploy the necessary machines.

3 Host with NAT network interface are deployed by default.

#### Initialization
Within the file `Vagrantfile` configure the deployment playbook you want to test via variable `$ansible_playbook`. Then bring the virtual machines up:
```bash
export instance_count=3
export ansible_playbook=deploy-docker.el7.swarm.yml
vagrant up
```

#### Execution of additional playbooks after provisioning
```bash
vagrant ssh centos-7-1
cd /vagrant
ansible-playbook -i /tmp/vagrant-ansible/inventory/vagrant_ansible_local_inventory <playbook>
exit
```

#### Destroy
```bash
vagrant destroy -f
```

## Preparations
There are some preparations that need to be done in order to get everything working.

### Ansible
Ansible is used to deploy the necessary environment and services to run this example. Therefore it must be installed on the deploying node. This can be achieved on CentOS by executing when EPEL-Repository is enabled:
```bash
sudo yum install -y ansible
```


## Docker - CentOS
In this scenario the rti-perftest example will be executed on single hosts with Docker 1.10 installed which is available in the extras-repository.
Weave-Net is used to connect the containers on the different hosts.

### Start
```bash
ansible-playbook -i demo deploy-docker.el7.yml
ansible-playbook -i demo rti-perftest-docker-start.yml
```

### Stop
```bash
ansible-playbook -i demo rti-perftest-docker-stop.yml
```

### Monitoring
Monitoring can be done using the tool cockpit which can be reached on the address `http://<host>:9090`.


## Docker - CentOS - Swarm Mode
In this scenario the rti-perftest example will be executed on hosts with Docker 1.10 which is available in the extras-repository and additionally configured as a swarm.
Weave-Net is used to connect the containers on the different hosts.

The difference to the former scenario is that it's not predefined on which host the containers are executed, just the number.

### Start
```bash
ansible-playbook -i demo deploy-docker.el7.swarm.yml
ansible-playbook -i demo rti-perftest-docker-swarm-start.yml
```

### Stop
```bash
ansible-playbook -i demo rti-perftest-docker-swarm-stop.yml
```

### Monitoring
Monitoring can be done using the tool cockpit which can be reached on the address `http://<host>:9090`. Cockpit has no support for Docker Swarm therefore every single host has to be monitored.

If you want to monitor using Weave-Scope you can enter the following command to deploy it:
```bash
ansible -i demo centos -a "scope launch"
```

### Remark
When operating with Docker Swarm before 1.12 the commands need to be prefixed with `docker -H tcp://<swarm manager>:2400 <command> <arguments>`.

Example(s):
```bash
docker -H tcp://192.168.198.101:2400 info
docker -H tcp://192.168.198.101:2400 ps
```


## Kubernetes - CentOS
In this scenario the rti-perftest example will be executed on a kubernetes cluster 1.3 which is available in the extras-repository.
Weave-Net is used to connect the containers on the different hosts.

### Start
```bash
ansible-playbook -i demo deploy-kubernetes.el7.yml
ansible-playbook -i demo rti-perftest-kubernetes-start.yml
```

### Stop
```bash
ansible-playbook -i demo rti-perftest-docker-stop.yml
```

### Monitoring
Monitoring can be done using the tool cockpit which can be reached on the address `http://<host>:9090`. It also supports Kubernetes and can be reached with the tab 'Cluster'.


## Kubernetes - kubernetes.io
In this scenario the rti-perftest example will be executed on a Kubernetes Cluster 1.5.1 with Docker 1.12 as container engine.
Weave-Net is used to connect the containers on the different hosts.

### Start
```bash
ansible-playbook -i demo deploy-kubernetes.main.yml
ansible-playbook -i demo rti-perftest-kubernetes-start.yml
```

### Stop
```bash
ansible-playbook -i demo rti-perftest-docker-stop.yml
```

### Monitoring
Monitoring can be done using Weave-Scope. To reach Weave-Scope from the host the following command needs to be executed on the master:
```bash
kubectl port-forward $(kubectl get pod --selector=weave-scope-component=app -o jsonpath='{.items..metadata.name}') 4040
```
Weave-Scope can then be reached on the address `http://<master>:4040`.


## Links
-   [Docker](http://www.docker.io)
-   [Kubernetes](http://www.kubernetes.io)
-   [Weave-Net](https://www.weave.works/products/weave-net/)
-   [Weave-Scope](https://www.weave.works/products/weave-scope/)
-   [Introducing docker-latest for RHEL 7 and RHEL Atomic Host](https://access.redhat.com/articles/2317361)
-   [Installing Kubernetes Cluster with 3 minions on CentOS 7 to manage pods and services](http://severalnines.com/blog/installing-kubernetes-cluster-minions-centos7-manage-pods-services)
