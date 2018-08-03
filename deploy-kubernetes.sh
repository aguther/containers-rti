#!/usr/bin/env bash

# define vm size and count
export VM_CPUS=2
export VM_MEMORY=2048
export VM_INSTANCES=3

# define playbook to run
export PLAYBOOK=deploy-kubernetes.yml

# destroy current vms
vagrant destroy -f

# create and start vms
vagrant up

# copy kubectl config
mkdir -p ~/.kube
cp -f .kube/config ~/.kube/config
