# -*- mode: ruby -*-
# # vi: set ft=ruby :

# required vagrant version
Vagrant.require_version ">= 1.9.0"
Vagrant.require_version "< 1.9.1"

# api version to be used
VAGRANTFILE_API_VERSION = "2"

# required plugins
require 'ipaddr'
require 'vagrant-hostmanager'

# define instances
$vm_instances = (ENV['VM_INSTANCES'] || 3).to_i
# ensure we have at least two instances
if $vm_instances < 2
  raise "This vagrantfile needs at least 2 instances to function properly. Please increase the value of 'instance_count'."
end

# define hostnames
$vm_hostname_prefix = (ENV['VM_HOSTNAME_PREFIX'] || "centos-").to_sym

# define virtual machine hardware
$vm_cpus = (ENV['VM_CPUS'] || 1).to_i
$vm_memory = (ENV['VM_MEMORY'] || 1024).to_i

# define virtual machine mode
$vm_gui = (ENV['VM_GUI']).to_s == "true" ? true : false

# define ip configuration
$vm_ip_template = (ENV['VM_IP_TEMPLATE'] || "172.30.0.%d").to_s
$vm_ip_netmask = (ENV['VM_IP_NETMASK'] || "255.255.255.0").to_s
$vm_ip_netmask_cidr = IPAddr.new($vm_ip_netmask).to_i.to_s(2).count("1")

# interface name
$vm_ip_interface_name = (ENV['VM_IP_INTERFACE_NAME'] || "eth1").to_s

# should the vm use a proxy?
if $vm_proxy_enabled = (ENV['VM_PROXY_ENABLED']).to_s == "true" ? true : false == true
  require 'vagrant-proxyconf'

  # this is the proxy address that will be used by the operating system
  $vm_proxy_address = (ENV['VM_PROXY_ADDRESS'] || "http://127.0.0.1:3128/").to_s
end

# define playbook
$playbook = (ENV['PLAYBOOK'] || "deploy-docker.yml").to_sym

# configure instances
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # ssh configuration
  config.ssh.insert_key = false
  config.ssh.username = 'vagrant'

  # update /etc/hosts to get working name resolution
  config.hostmanager.enabled = true
  config.hostmanager.manage_host = false
  config.hostmanager.manage_guest = true
  config.hostmanager.ignore_private_ip = false
  config.hostmanager.include_offline = true

  # when plugin proxyconf is installed, use it
  if $vm_proxy_enabled == true
      config.proxy.enabled = true
      config.proxy.http = $vm_proxy_address
      config.proxy.https = $vm_proxy_address
  end

  # create virtual machines
  ($vm_instances).downto(1) do |id|
    # create hostname
    hostname = "%s%d" % [$vm_hostname_prefix, id]
    # define the virtual machine
    config.vm.define hostname, primary: (id == 1) ? true : false do |instance_config|
      # hostname within virtual machine
      instance_config.vm.hostname = hostname
      # define image to be used
      instance_config.vm.box = "bento/centos-7.3"
      # enable synced folder
      instance_config.vm.synced_folder ".", "/vagrant"
      # private network for connection between virtual machines
      instance_config.vm.network :private_network,
        ip: $vm_ip_template % (10 + id),
        netmask: $vm_ip_netmask

      # virtual box settings
      instance_config.vm.provider :virtualbox do |vbox, override|
        vbox.gui = $vm_gui
        vbox.cpus = $vm_cpus
        vbox.memory = $vm_memory
        vbox.customize ["modifyvm", :id, "--nictype1", "virtio"]
        vbox.customize ["modifyvm", :id, "--nictype2", "virtio"]
      end

      # vmware settings
      [:vmware_fusion, :vmware_workstation].each do |provider|
        instance_config.vm.provider provider do |vmware, override|
          vmware.gui = $vm_gui
          vmware.vmx["numvcpus"] = $vm_cpus
          vmware.vmx["memsize"] = $vm_memory
        end
      end

      # provision proxy configuration for docker
      if $vm_proxy_enabled == true
        instance_config.vm.provision :shell do |shell|
          shell.path = "proxy/set-proxy-docker.sh"
          shell.args = [
            $vm_proxy_address,
          ]
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
          ansible.playbook = "/vagrant/%s" % $playbook
          # target group
          ansible.limit = "centos"
          # run as sudo
          ansible.sudo = true
          # logging verbosity
          ansible.verbose = false
          # groups
          ansible.groups = {
            "master" => "%s1" % $vm_hostname_prefix,
            "nodes" => "%s[2:%d]" % [$vm_hostname_prefix, $vm_instances],
            "centos:children" => [
              "master",
              "nodes",
            ],
            "centos:vars" => {
              "ansible_ssh_pass" => config.ssh.username,
            },
          }
          # extra variables to configure roles
          ansible.extra_vars = {
            docker_group_users: "vagrant",
            docker_swarm_interface: $vm_ip_interface_name,
            etcd_interface: $vm_ip_interface_name,
            flannel_interface: $vm_ip_interface_name,
          }
        end
      end
    end
  end
end
