# containers-rti
Repository to test RTI DDS with container technologies (docker, kubernetes).

# Environment
The following describes the environment that was in mind for this example.

3 Hosts with the latest CentOS 7:
- centos-7-1 with IPv4 = 192.168.198.101
- centos-7-2 with IPv4 = 192.168.198.102
- centos-7-3 with IPv4 = 192.168.198.103

Default-Gateway, DNS = 192.168.198.2

# Preparations
There are some preparations that need to be done in order to get everything working.

## Ansible
Ansible is used to deploy the necessary environment and services to run this example. Therefore it must be installed on the deploying node. This can be achieved on CentOS by executing:
sudo yum install -y ansible

# Docker - CentOS
The example with rti-perftest can be executed on docker (version 1.10) by entering the following command:
ansible-playbook -i demo deploy-docker.el7.yml
ansible-playbook -i demo rti-perftest-docker-start.yml

To stop the example enter the following command:
ansible-playbook -i demo rti-perftest-docker-stop.yml

Monitoring can be done using the tool cockpit which can be reached on the address 'http://<IP>:9090'.

# Kubernetes - CentOS
The kubernetes cluster (version 1.3) can be deployed with the example using the following command:
ansible-playbook -i demo deploy-kubernetes.el7.yml
ansible-playbook -i demo rti-perftest-kubernetes-start.yml

To stop the example enter the following command:
ansible-playbook -i demo rti-perftest-docker-stop.yml

Monitoring can be done using the tool cockpit which can be reached on the address 'http://<IP>:9090'.

# Docker - docker.io
The example with rti-perftest can be executed on docker (1.12) by entering the following command:
ansible-playbook -i demo deploy-docker.main.yml
ansible-playbook -i demo rti-perftest-docker-start.yml

To stop the example enter the following command:
ansible-playbook -i demo rti-perftest-docker-stop.yml

# Kubernetes - kubernetes.io
The kubernetes cluster (version 1.5.1) can be deployed with the example using the following command:
ansible-playbook -i demo deploy-kubernetes.main.yml
ansible-playbook -i demo rti-perftest-kubernetes-start.yml

To stop the example enter the following command:
ansible-playbook -i demo rti-perftest-docker-stop.yml

# Links
https://access.redhat.com/articles/2317361
http://severalnines.com/blog/installing-kubernetes-cluster-minions-centos7-manage-pods-services
https://www.weave.works/products/weave-net/
https://www.weave.works/weave-net-kubernetes-integration/
