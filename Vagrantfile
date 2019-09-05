# -*- mode: ruby -*-
# vi: set ft=ruby :
#

BOXIMAGE = "ubuntu/bionic64"

Vagrant.configure("2") do |config|

  config.vm.box = BOXIMAGE

  config.vm.provision "pre-check-and-configure", type: "shell", path: "scripts/pre_check_and_configure.sh"
  config.vm.provision "install-docker", type: "shell", path: "scripts/install_docker.sh"
  config.vm.provision "install-kubeadm", type: "shell", path: "scripts/install_kubeadm.sh"

end
