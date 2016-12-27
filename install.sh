#!/usr/bin/env bash

# check if we are root
if [ $(id -u) != 0 ]
  then echo "Please execute this script as root!"
  exit 1
fi

# install dependencies
yum install -y ntp

# install docker and docker-latest
yum install -y docker docker-latest

# install kubernetes
yum install -y etcd kubernetes flannel

# install cockpit (makes monitoring easier)
yum install -y cockpit

# install weave (but do not launch)
curl -L git.io/weave -o /usr/local/bin/weave
chmod a+x /usr/local/bin/weave

# install scope (but do not launch)
curl -L git.io/scope -o /usr/local/bin/scope
chmod a+x /usr/local/bin/scope

# enable cockpit
systemctl enable --now cockpit.socket
sudo firewall-cmd --permanent --zone=public --add-service=cockpit
sudo firewall-cmd --reload

# enable ntp
systemctl enable --now ntpd

# disable firewall
systemctl disable --now firewalld

# enable docker-latest daemon
systemctl disable --now docker
systemctl enable --now docker-latest

# TODO: enable docker-latest client
# /etc/sysconfig/docker --> DOCKERBINARY=/usr/bin/docker-latest
