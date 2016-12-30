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

# Docker
The example with rti-perftest can be executed by entering the following command:
ansible-playbook -i demo plays/rti-perftest/start.yml

To stop the example execute:
ansible-playbook -i demo plays/rti-perftest/stop.yml

# Kubernetes
WARNING: kubernetes from extras repository on CentOS 7 is not compatible with package docker-latest.

The kubernetes cluster can be deployed using the following command:
ansible-playbook -i demo plays/kubernetes/deploy.yml

# Links
https://access.redhat.com/articles/2317361
http://severalnines.com/blog/installing-kubernetes-cluster-minions-centos7-manage-pods-services
https://www.weave.works/products/weave-net/
https://www.weave.works/weave-net-kubernetes-integration/
