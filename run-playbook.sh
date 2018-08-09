#!/usr/bin/env bash

# run playbook
vagrant ssh -c "pushd /vagrant && ansible-playbook -i /tmp/vagrant-ansible/inventory/vagrant_ansible_local_inventory $1"
