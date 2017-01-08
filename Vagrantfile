# -*- mode: ruby -*-
# # vi: set ft=ruby :

# minimum vagrant version
Vagrant.require_version ">= 1.9.0"

# api version to be used
VAGRANTFILE_API_VERSION = "2"

# define instances
$instance_name_prefix = "centos-7-"
$instance_count = 3
# load instance_count also from environment when defined
if ENV['instance_count']
  $instance_count = ENV['instance_count'].to_i
end
# ensure we have at least two instances
if $instance_count < 2
  raise "This vagrantfile needs at least 2 instances to function properly. Please increase the value of 'instance_count'."
end

# define virtual machine hardware / mode
$vm_cpus = 1
$vm_memory = 1024
$vm_gui = false
$vm_proxy_enabled = false

# define default playbook
$ansible_playbook = "deploy-docker.el7.swarm.yml"
# load ansible_playbook also from environment when defined
if ENV['ansible_playbook']
  $ansible_playbook = ENV['ansible_playbook'].to_s
end

# configure instances
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # ssh configuration
  config.ssh.insert_key = false
  config.ssh.username = 'vagrant'

  # update /etc/hosts to get working name resolution
  if Vagrant.has_plugin?("vagrant-hostmanager")
    config.hostmanager.enabled = true
    config.hostmanager.manage_host = false
    config.hostmanager.manage_guest = true
    config.hostmanager.ignore_private_ip = false
    config.hostmanager.include_offline = true
  else
    raise "Please run 'vagrant plugin install vagrant-hostmanager' to use this vagrantfile."
  end

  # when plugin proxyconf is installed, use it
  if $vm_proxy_enabled == true
    if Vagrant.has_plugin?("vagrant-proxyconf")
      config.proxy.enabled = true
      config.proxy.http = "http://127.0.0.1:3128/"
      config.proxy.https = "http://127.0.0.1:3128/"
      config.proxy.no_proxy = "localhost,127.0.0.1"
    end
  end

  # create virtual machines
  ($instance_count).downto(1) do |id|
    # create hostname
    hostname = "%s%d" % [$instance_name_prefix, id]
    # define the virtual machine
    config.vm.define hostname, primary: (id == 1) ? true : false do |instance_config|
      # hostname within virtual machine
      instance_config.vm.hostname = hostname
      # define image to be used
      instance_config.vm.box = "bento/centos-7.3"
      # enable synced folder
      instance_config.vm.synced_folder ".", "/vagrant"

      # virtual box settings
      instance_config.vm.provider :virtualbox do |vbox, override|
        vbox.gui = $vm_gui
        vbox.cpus = $vm_cpus
        vbox.memory = $vm_memory
        # private network for connection between virtual machines
        override.vm.network :private_network,
          ip: "172.20.0.%d" % (100 + id),
          netmask: "255.255.255.0"
        # bugfix for #8166 (private network is not up after vagrant up)
        override.vm.provision :shell,
          inline: "sudo ifup enp0s8"
      end

      # vmware settings
      [:vmware_fusion, :vmware_workstation].each do |provider|
        instance_config.vm.provider provider do |vmware, override|
          vmware.gui = $vm_gui
          vmware.vmx["numvcpus"] = $vm_cpus
          vmware.vmx["memsize"] = $vm_memory
        end
      end

      # provision cntlm if proxy shall be used
      if $vm_proxy_enabled == true
        instance_config.vm.provision :ansible_local do |ansible|
          # ensure ansible is installed
          ansible.install = true
          # define playbook to execute
          ansible.playbook = "/vagrant/deploy-cntlm.yml"
          # allow to connect to all instances
          ansible.limit = "localhost"
          # run as sudo
          ansible.sudo = true
          # logging verbosity
          ansible.verbose = false
        end
      end

      # add vagrant user to group wheel
      instance_config.vm.provision :shell,
        inline: "sudo usermod -a -G wheel %s" % config.ssh.username

      # provision using ansible, but only once and not for every instance
      if id == 1
        instance_config.vm.provision :ansible_local do |ansible|
          # ensure ansible is installed
          ansible.install = true
          # define playbook to execute
          ansible.playbook = "/vagrant/%s" % $ansible_playbook
          # allow to connect to all instances
          ansible.limit = "centos"
          # run as sudo
          ansible.sudo = true
          # logging verbosity
          ansible.verbose = false
          # groups
          ansible.groups = {
            "master" => "%s1" % $instance_name_prefix,
            "nodes" => "%s[2:%d]" % [$instance_name_prefix, $instance_count],
            "centos:children" => [
              "master",
              "nodes",
            ],
            "centos:vars" => {
              "ansible_ssh_pass" => config.ssh.username,
            },
          }
        end
      end
    end
  end
end
