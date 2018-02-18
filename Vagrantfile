# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|

  config.ssh.username = "ubuntu"

  config.jsonconfig.load_json "secrets.json", nil, true

  db_root_password = config.jsonconfig.get "db_root_password"
  db_name = config.jsonconfig.get "db_name"
  db_user = config.jsonconfig.get "db_user"
  db_password = config.jsonconfig.get "db_password"
  test_db_name = config.jsonconfig.get "test_db_name"


  def provisioning(config, provision_script_path, shell_arguments)
    config.vm.provision "shell", privileged: false,
    path: provision_script_path, args: shell_arguments
  end

  excludes = [".git/","venv/","run/","/logs"]
  config.vm.synced_folder ".", "/vagrant/ci_dashboard", type: "rsync",
    rsync__exclude: excludes, rsync_excludes: excludes

  config.vm.define "dev" do |dev|
    dev.vm.box = "ubuntu/xenial64"
    dev.vm.hostname = "django-dev"

    dev.ssh.username = "vagrant"
    provision_script_path = "provision/dev_provision.sh"

    django_settings_module = config.jsonconfig.get "dev_django_settings_module"
    project_requirements = config.jsonconfig.get "dev_project_requirements"

    provisioning(dev, provision_script_path, [db_root_password,db_name,db_user,db_password,
      test_db_name,django_settings_module,project_requirements])

    dev.vm.network :forwarded_port, host: 8000, guest: 8000, host_ip: "127.0.0.1"
  end

  config.vm.define "prod" do |prod|

    provision_script_path = "provision/prod_provision.sh"

    django_settings_module = config.jsonconfig.get "prod_django_settings_module"
    project_requirements = config.jsonconfig.get "prod_project_requirements"
    server_name = config.jsonconfig.get "server_name"


    provisioning(prod, provision_script_path, [db_root_password,db_name,db_user,db_password,
      test_db_name,django_settings_module,project_requirements,server_name])

      prod.vm.provider :digital_ocean do |provider, override|
        override.ssh.private_key_path = '~/.ssh/id_rsa'
        override.vm.box = 'digital_ocean'
        override.vm.box_url = "https://github.com/devopsgroup-io/vagrant-digitalocean/raw/master/box/digital_ocean.box"
        override.nfs.functional = false
        provider.token = config.jsonconfig.get "do_token"
        provider.image = 'ubuntu-16-04-x64'
        provider.region = 'fra1'
        provider.size = 's-1vcpu-1gb'
      end
  end
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.


  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # NOTE: This will enable public access to the opened port
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine and only allow access
  # via 127.0.0.1 to disable public access
  # config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
  #   vb.memory = "1024"
  # end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Define a Vagrant Push strategy for pushing to Atlas. Other push strategies
  # such as FTP and Heroku are also available. See the documentation at
  # https://docs.vagrantup.com/v2/push/atlas.html for more information.
  # config.push.define "atlas" do |push|
  #   push.app = "YOUR_ATLAS_USERNAME/YOUR_APPLICATION_NAME"
  # end

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", inline: <<-SHELL
  #   apt-get update
  #   apt-get install -y apache2
  # SHELL
end
