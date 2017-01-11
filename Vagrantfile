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
$instance_name_prefix = (ENV['INSTANCE_NAME_PREFIX'] || "centos-").to_sym
$instance_count = (ENV['INSTANCE_COUNT'] || 3).to_i
# ensure we have at least two instances
if $instance_count < 2
  raise "This vagrantfile needs at least 2 instances to function properly. Please increase the value of 'instance_count'."
end

# define virtual machine hardware
$vm_cpus = (ENV['VM_CPUS'] || 1).to_i
$vm_memory = (ENV['VM_MEMORY'] || 1024).to_i

# define virtual machine mode
$vm_gui = (ENV['VM_GUI']).to_s == "true" ? true : false

# define ip configuration
$vm_ip_template = (ENV['VM_IP_TEMPLATE'] || "172.16.0.%d").to_s
$vm_ip_netmask = (ENV['VM_IP_NETMASK'] || "255.255.255.0").to_s
$vm_ip_netmask_cidr = IPAddr.new($vm_ip_netmask).to_i.to_s(2).count("1")
$vm_ip_template_network = $vm_ip_template % 0
$vm_ip_template_network_cidr = "%s/%d" % [$vm_ip_template_network, $vm_ip_netmask_cidr]
$vm_ip_interface_name = "ens33"

# should the vm use a proxy?
$vm_proxy_enabled = (ENV['VM_PROXY_ENABLED']).to_s == "true" ? true : false
if $vm_proxy_enabled == true
  require 'vagrant-proxyconf'

  $cntlm_rpm = (ENV['CNTLM_RPM'] || "cntlm/cntlm-0.92.3-1.x86_64.rpm").to_s
  $cntlm_username = (ENV['CNTLM_USERNAME'] || "USER").to_s
  $cntlm_domain = (ENV['CNTLM_DOMAIN'] || "DOMAIN").to_s
  $cntlm_pass_auth = (ENV['CNTLM_PASS_AUTH'] || "NTLMv2").to_s
  $cntlm_pass_hash = (ENV['CNTLM_PASS_HASH'] || "PASSHASH").to_s
  $cntlm_proxy_address = (ENV['CNTLM_PROXY_ADDRESS'] || "http://proxy.company.domain:8080").to_s

  $cntlm_listening_port = 3128
  $cntlm_address = "http://127.0.0.1:%d/" % $cntlm_listening_port

  $cntlm_no_proxy = "localhost,127.0.0.1"
  $cntlm_no_proxy += ",10.*"
  (16..31).each do |ip_part|
    $cntlm_no_proxy += ",172.%d.*" % ip_part
  end
  $cntlm_no_proxy += ",192.168.*"
  $cntlm_no_proxy += ",%s*" % $instance_name_prefix
  $cntlm_no_proxy += ",%s" % ENV['CNTLM_NO_PROXY'].to_s
end

# define playbook
$ansible_playbook = (ENV['ANSIBLE_PLAYBOOK'] || "deploy-docker-swarm.yml").to_sym

# configure instances
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # ssh configuration
  #config.ssh.pty = true
  config.ssh.insert_key = false
  config.ssh.username = 'vagrant'

  # define order for providers
  config.vm.provider "vmware_workstation"
  config.vm.provider "vmware_fusion"
  config.vm.provider "virtualbox"
  config.vm.provider "libvirt"

  # update /etc/hosts to get working name resolution
  config.hostmanager.enabled = true
  config.hostmanager.manage_host = false
  config.hostmanager.manage_guest = true
  config.hostmanager.ignore_private_ip = false
  config.hostmanager.include_offline = true

  # when plugin proxyconf is installed, use it
  if $vm_proxy_enabled == true
      config.proxy.enabled = true
      config.proxy.http = $cntlm_address
      config.proxy.https = $cntlm_address
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
      # private network for connection between virtual machines
      instance_config.vm.network :private_network,
        ip: $vm_ip_template % (100 + id),
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

      # provision cntlm if proxy shall be used
      if $vm_proxy_enabled == true
        # copy cntlm rpm
        instance_config.vm.provision :file do |file|
          file.source = $cntlm_rpm
          file.destination = "/tmp/cntlm.rpm"
        end

        # deploy cntlm including configuration
        instance_config.vm.provision :shell do |shell|
          shell.path = "cntlm/deploy-cntlm.sh"
          shell.args = [
            $cntlm_proxy_address,
            $cntlm_listening_port,
            $cntlm_domain,
            $cntlm_username,
            $cntlm_pass_auth,
            $cntlm_pass_hash,
            $cntlm_no_proxy,
            $cntlm_address,
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
          ansible.playbook = "/vagrant/%s" % $ansible_playbook
          # target group
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
