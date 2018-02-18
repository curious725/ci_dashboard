#!/bin/bash

cd /vagrant/ci_dashboard/provision
. base_provision.sh


cd /vagrant/ci_dashboard/src
python manage.py collectstatic --settings=$DJANGO_SETTINGS_MODULE


dpkg -s nginx &>/dev/null || {
  sudo apt-get install -y nginx
}

dpkg -s supervisor &>/dev/null || {
  sudo apt-get install -y supervisor
}

sudo systemctl enable supervisor
sudo systemctl start supervisor

cd /vagrant/ci_dashboard/config

chmod u+x gunicorn_start

cd /vagrant/ci_dashboard/
mkdir run logs

sudo cp /vagrant/ci_dashboard/config/ci_dashboard.supervisor.conf /etc/supervisor/conf.d/ci_dashboard.supervisor.conf


sudo supervisorctl reread
sudo supervisorctl update

sudo service supervisor restart

sudo rm /etc/nginx/sites-enabled/default
sudo rm /etc/nginx/sites-available/default

sudo cp /vagrant/ci_dashboard/config/ci_dashboard.nginx.conf /etc/nginx/sites-available/ci_dashboard.nginx.conf

sudo sed -i "s/server_name ;/server_name $SERVER_NAME;/" /etc/nginx/sites-available/ci_dashboard.nginx.conf

sudo ln -s /etc/nginx/sites-available/ci_dashboard.nginx.conf /etc/nginx/sites-enabled/ci_dashboard.nginx.conf
sudo service nginx restart

