# containers-rti
Repository to test RTI DDS with container technologies (docker, kubernetes).

# Environment
This repository has the following setup in mind.

3 Hosts with the latest CentOS 7:
- centos-7-1 with IPv4 = 192.168.198.101
- centos-7-2 with IPv4 = 192.168.198.102
- centos-7-3 with IPv4 = 192.168.198.103

Default-Gateway, DNS = 192.168.198.2

# Preparations
There are some preparations that need to be done in order to get everything working.

## CentOS
Disable strict host checking for SSH if you want to use passwords with ansible.

Therefore you need to create a file ~/.ssh/config with the following content:
Host *
    StrictHostKeyChecking no

# Kubernetes

WARNING: kubernetes from extras repository on CentOS 7 is not compatible with package docker-latest.

Master:
1. see install.sh
2. edit /etc/etcd/etcd.conf
   ETCD_LISTEN_CLIENT_URLS="http://0.0.0.0:2379"
3. edit /etc/kubernetes/apiserver
   KUBE_API_ADDRESS="--insecure-bind-address=0.0.0.0"
4. for SERVICES in etcd kube-apiserver kube-controller-manager kube-scheduler; do systemctl restart $SERVICES; systemctl enable $SERVICES; systemctl status $SERVICES; done
5. etcdctl mk /atomic.io/network/config '{"Network":"172.17.0.0/16"}'

Nodes:
1. edit /etc/sysconfig/flanneld
   FLANNEL_ETCD="http://192.168.198.101:2379"
2. edit /etc/kubernetes/config
   KUBE_MASTER="http://192.168.198.101:8080"
3. edit /etc/kubernetes/kubelet
   KUBELET_ADDRESS="--address=0.0.0.0"
   KUBELET_HOSTNAME="--hostname-override=192.168.198.102"
   KUBELET_API_SERVER="--api-servers=http://192.168.198.101:8080"
4. for SERVICES in kube-proxy kubelet docker flanneld; do systemctl restart $SERVICES; systemctl enable $SERVICES; systemctl status $SERVICES; done

# Links
https://access.redhat.com/articles/2317361
http://severalnines.com/blog/installing-kubernetes-cluster-minions-centos7-manage-pods-services
https://www.weave.works/products/weave-net/
https://www.weave.works/weave-net-kubernetes-integration/
