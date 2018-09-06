# -*- mode: ruby -*-
# # vi: set ft=ruby :

# required vagrant version
Vagrant.require_version ">= 2.1.0"

# required plugins
require 'ipaddr'

# define instances
$vm_instances = (ENV['VM_INSTANCES'] || 2).to_i
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
if $vm_proxy_enabled = (ENV['VM_PROXY']).to_s != "" ? true : false == true
  require 'vagrant-proxyconf'

  # this is the proxy address that will be used by the operating system
  $vm_proxy_address = (ENV['VM_PROXY']).to_s

  # define servers that should not use a proxy
  $vm_no_proxy = "localhost,127.0.0.1,10.0.2.0/24,10.96.0.0/16,172.30.0.0/16,*.default,centos-1,centos-2,centos-3,centos-4,centos-5,centos-6,centos-7,centos-8"
end

# define playbook
$playbook = (ENV['PLAYBOOK'] || "")
# check if playbook file exists if specified
if ($playbook != "") & (!File.exists? File.expand_path($playbook))
  raise "Playbook does not exist!"
end

# configure instances
Vagrant.configure("2") do |config|
  # ssh configuration
  config.ssh.insert_key = false
  config.ssh.username = 'vagrant'

  # disable update of guest additions
  config.vbguest.auto_update = false
  config.vbguest.no_install = true
  config.vbguest.no_remote = true

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
      config.proxy.no_proxy = $vm_no_proxy
  end

  # create virtual machines
  ($vm_instances).downto(1) do |id|
    # create hostname
    hostname = "%s%d.vm" % [$vm_hostname_prefix, id]
    # define the virtual machine
    config.vm.define hostname, primary: (id == 1) ? true : false do |instance_config|
      # hostname within virtual machine
      instance_config.vm.hostname = hostname
      # define image to be used
      instance_config.vm.box = "bento/centos-7.5"
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
      config.vm.provider :vmare_workstation do |vmware, override|
        vmware.gui = $vm_gui
        vmware.vmx["numvcpus"] = $vm_cpus
        vmware.vmx["memsize"] = $vm_memory
        vmware.vmx["ethernet0.pcislotnumber"] = "33"
      end

      # provision proxy configuration for docker
      if $vm_proxy_enabled == true
        instance_config.vm.provision :shell do |shell|
          shell.path = "proxy/set-proxy-docker.sh"
          shell.args = [
            $vm_proxy_address,
            $vm_no_proxy
          ]
        end
      end

      # add vagrant user to group wheel
      instance_config.vm.provision :shell,
        privileged: true,
        inline: "usermod -a -G wheel %s" % config.ssh.username

      # provision using ansible, but only once and not for every instance
      if ($playbook != "") & (id == 1)
        instance_config.vm.provision :ansible_local do |ansible|
          # ensure ansible is installed
          ansible.install = true
          # define playbook to execute
          ansible.playbook = "/vagrant/%s" % $playbook
          # target group
          ansible.limit = "centos"
          # run as sudo
          ansible.become = true
          # logging verbosity
          ansible.verbose = false
          # skip tags
          ansible.skip_tags = "os-hosts"
          # groups
          ansible.groups = {
            "master" => "%s1.vm" % $vm_hostname_prefix,
            "nodes" => "%s[2:%d].vm" % [$vm_hostname_prefix, $vm_instances],
            "centos:children" => [
              "master",
              "nodes",
            ],
            "centos:vars" => {
              "ansible_ssh_pass" => config.ssh.username,
            },
            "datacenter-1" => "%s[1:%d].vm\n" % [$vm_hostname_prefix, $vm_instances / 2],
            "datacenter-2" => "%s[%d:%d].vm\n" % [$vm_hostname_prefix, $vm_instances / 2 + 1, $vm_instances],
          }
          # extra variables to configure roles
          ansible.extra_vars = {
            ansible_ssh_common_args: '-o StrictHostKeyChecking=no',
            docker_group_users: "vagrant",
            docker_registry_port: "5000",
            docker_registry_auth_user: "docker-registry",
            docker_registry_auth_password: "P@ssw0rd",
            kubernetes_interface: $vm_ip_interface_name,
            kubernetes_self_hosting: "no",
            metallb_addresses: [
              "172.30.0.100-172.30.0.199"
            ],
            kubernetes_dashboard_service_type: "LoadBalancer",
            kubernetes_dashboard_service_port: "80",
            kubernetes_dashboard_service_ip: "172.30.0.100",
            consul_interface: $vm_ip_interface_name,
            nomad_interface: $vm_ip_interface_name
          }
        end
      end
    end
  end
end