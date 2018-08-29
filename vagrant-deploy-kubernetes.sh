#!/usr/bin/env bash

# define vm size and count
export VM_CPUS=${VM_CPUS:=2}
export VM_MEMORY=${VM_MEMORY:=3072}
export VM_INSTANCES=${VM_INSTANCES:=4}

# define playbook to run
export PLAYBOOK=${PLAYBOOK:=deploy-kubernetes.yml}

# print values
echo
echo Deployment configuration:
echo VM_CPUS=${VM_CPUS}
echo VM_MEMORY=${VM_MEMORY}
echo VM_INSTANCES=${VM_INSTANCES}
if [[ -v VM_PROXY ]]; then
    echo VM_PROXY=${VM_PROXY}
fi
echo
echo PLAYBOOK=${PLAYBOOK}
echo

# destroy current vms
vagrant destroy -f

# create and start vms
vagrant up

# copy kubectl config
mkdir -p ~/.kube
cp -f .kube/config ~/.kube/config
