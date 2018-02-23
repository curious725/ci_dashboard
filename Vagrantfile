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
end
