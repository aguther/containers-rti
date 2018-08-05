#!/usr/bin/env bash

# load docker images
vagrant ssh -c "pushd /vagrant && ansible-playbook -i /tmp/vagrant-ansible/inventory/vagrant_ansible_local_inventory load-docker-images.yml"

# deploy helm chart rti-shapes-demo
vagrant ssh -c "pushd /vagrant && ansible-playbook -i /tmp/vagrant-ansible/inventory/vagrant_ansible_local_inventory rti-shapes-demo.yml"
