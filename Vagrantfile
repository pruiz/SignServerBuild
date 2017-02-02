# -*- mode: ruby -*-
# vi: set ft=ruby :

# Minimun vagrant version required for this environment.
Vagrant.require_version ">= 1.7.4"

Vagrant.configure(2) do |config|

  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
  config.vm.box = "bento/centos-6.7"
  config.vm.box_version = "2.2.1"
  config.vm.hostname = "srv.signserver.dev"

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  config.vm.synced_folder ".salt", "/srv/salt", create: true, owner: "root", group: "root"

  # Ensure we uselinked-clones under parallels.
  config.vm.provider "parallels" do |prov|
     if prov.respond_to?("linked_clone") then prov.linked_clone else prov.use_linked_clone end
  end

  config.ssh.forward_agent = true
  config.ssh.forward_x11 = true

  # Install/Update ca-certificates package..
  config.vm.provision "shell", inline: <<-SHELL
    yum --disablerepo=\* --enablerepo=base --enablerepo=updates upgrade ca-certificates
    update-ca-trust
    mkdir -p /etc/salt
    cp /srv/salt/config/minion /etc/salt/minion
    mkdir -p /tmp/salt-config
    cp /srv/salt/config/minion /tmp/salt-config/minion
  SHELL

  # Enable provisioning with salt (masteless).
  config.vm.provision :salt do |salt|
    salt.verbose = true
    salt.bootstrap_options = "-F -Z -p ca-certificates -p which -p libselinux-python -c /tmp/salt-config"
    salt.colorize = true
    #salt.minion_config = "salt/minion.conf"
    salt.run_highstate = true
  end
end
