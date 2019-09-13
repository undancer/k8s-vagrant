# -*- mode: ruby -*-
# vi: set ft=ruby :
#

BOXIMAGE = "ubuntu/bionic64"
MASTER_IP = "192.168.33.100"
NODE_IP_NW = "192.168.33."
KUBEADM_POD_NETWORK_CIDR = "10.244.0.0/16"
KUBEADM_TOKEN = "breath.kubernetes123456"
KUBEADM_TOKEN_TTL = 0
NUM_NODE = 2

Vagrant.configure("2") do |config|

  config.vm.box = BOXIMAGE

  config.vm.provision "pre-check-and-configure", type: "shell", path: "scripts/pre_check_and_configure.sh"
  config.vm.provision "install-docker", type: "shell", path: "scripts/install_docker.sh"
  config.vm.provision "install-kubeadm", type: "shell", path: "scripts/install_kubeadm.sh"

  masters = 1..3

  clusters = masters.map.with_index { |master, index| "infra#{index}=https://#{NODE_IP_NW}#{10 + master}:2380" }.join(",")

  (masters).each_with_index do |m, i|
    config.vm.define "master-#{m}" do |master|
      master.vm.hostname = "master-#{m}"
      host = NODE_IP_NW + "#{10 + m}"
      name = "infra#{i}"
      master.vm.network "private_network", ip: host, auto_config: true

      master.vm.provision "install-etcd", type: "shell", path: "scripts/install_etcd.sh", args: [host, name, clusters]

    end
  end

end
