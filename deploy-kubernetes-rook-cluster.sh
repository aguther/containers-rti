#!/usr/bin/env bash

# deploy rook-cluster
vagrant ssh -c "pushd /vagrant && ansible-playbook -i /tmp/vagrant-ansible/inventory/vagrant_ansible_local_inventory deploy-rook-cluster.yml"
