#!/bin/bash

DB_ROOT_PASSWORD=$1
DB_NAME=$2
DB_USER=$3
DB_PASSWORD=$4
TEST_DB_NAME=$5
DJANGO_SETTINGS_MODULE=$6
PROJECT_REQUIREMENTS=$7
SERVER_NAME=$8


sudo mkdir /var/log/setup

# fix possible locale issues
if [ ! -f /var/log/setup/locale ];
then
  echo "# Locale settings
  export LANGUAGE=en_US.UTF-8
  export LANG=en_US.UTF-8
  export LC_ALL=en_US.UTF-8">>~/.bashrc
  source ~/.bashrc

  sudo locale-gen en_US.UTF-8
  sudo dpkg-reconfigure --frontend=noninteractive locales

  sudo touch /var/log/setup/locale
fi

# # update PYTHONPATH
grep -q -F "export PYTHONPATH=$PYTHONPATH:/vagrant/ci_dashboard/src" ~/.bashrc || \
echo "export PYTHONPATH=$PYTHONPATH:/vagrant/ci_dashboard/src" >> ~/.bashrc && \
source ~/.bashrc

# #Updating and instaling dependencies
sudo apt-get update
sudo apt-get -y upgrade

# Ensure that we have a robust set-up for our programming environment
dpkg -s build-essential &>/dev/null || {
  sudo apt-get install -y build-essential
}

dpkg -s libssl-dev &>/dev/null || {
  sudo apt-get install -y libssl-dev
}

dpkg -s libffi-dev &>/dev/null || {
  sudo apt-get install -y libffi-dev
}

# Install Python 3.6
sudo add-apt-repository -y  ppa:deadsnakes/ppa
sudo apt-get update

dpkg -s python3.6 &>/dev/null || {
  sudo apt-get install -y python3.6
}

dpkg -s python3.6-venv &>/dev/null || {
  sudo apt-get install -y python3.6-venv
}

dpkg -s python3.6-dev &>/dev/null || {
  sudo apt-get install -y python3.6-dev
}

# Dependencies for image processing with Pillow (drop-in replacement for PIL)
# supporting: jpeg, tiff, png, freetype, littlecms
dpkg -s libjpeg-dev &>/dev/null || {
    sudo apt-get install -y libjpeg-dev
}

dpkg -s libtiff5-dev &>/dev/null || {
    sudo apt-get install -y libtiff5-dev
}

dpkg -s zlib1g-dev &>/dev/null || {
    sudo apt-get install -y zlib1g-dev
}

dpkg -s libfreetype6-dev &>/dev/null || {
    sudo apt-get install -y libfreetype6-dev
}

dpkg -s liblcms2-dev &>/dev/null || {
    sudo apt-get install -y liblcms2-dev
}

dpkg -s libncurses5-dev &>/dev/null || {
  sudo apt-get install -y libncurses5-dev
}

# Git (we'd rather avoid people keeping credentials for git commits in the repo,
# but sometimes we need it for pip requirements that aren't in PyPI)
dpkg -s git &>/dev/null || {
    sudo apt-get install -y git
}

# MySQL
dpkg -s mysql-server-5.7 &>/dev/null || {
  sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password root"
  sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password root"

  # Install MySQL 5.7
  sudo apt-get install -y mysql-server-5.7

  # Install Expect
  dpkg -s expect &>/dev/null || {
    sudo apt-get install -y expect
  }

  # Run mysql_secure_installation to secure installation
  SECURE_MYSQL=$(expect -c "
  set timeout 10
  spawn mysql_secure_installation
  expect \"Enter current password for root:\"
  send \"root\r\"
  expect \"Would you like to setup VALIDATE PASSWORD plugin?\"
  send \"n\r\"
  expect \"Change the password for root ?\"
  send \"n\r\"
  expect \"Remove anonymous users?\"
  send \"y\r\"
  expect \"Disallow root login remotely?\"
  send \"y\r\"
  expect \"Remove test database and access to it?\"
  send \"y\r\"
  expect \"Reload privilege tables now?\"
  send \"y\r\"
  expect eof
  ")

  echo "$SECURE_MYSQL"

  # Remove Expect
  sudo apt-get purge -y expect
}

sudo cp /vagrant/boards/config/overrides.my.cnf /etc/mysql/mysql.conf.d/overrides.my.cnf
sudo service mysql restart

# Setup of database
if [ ! -f /var/log/setup/ci_dashboarddatabase ];
then
  mysql -uroot -proot -e "
  USE mysql;
  CREATE DATABASE $DB_NAME DEFAULT CHARACTER SET utf8
  DEFAULT COLLATE utf8_general_ci;
  CREATE USER '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASSWORD';
  GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';
  GRANT ALL PRIVILEGES ON $TEST_DB_NAME.* TO '$DB_USER'@'localhost';
  FLUSH PRIVILEGES;
  ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$DB_ROOT_PASSWORD';
  "
  sudo touch /var/log/setup/ci_dashboarddatabase

fi

# helps MySQL cooperate with Python
dpkg -s libmysqlclient-dev &>/dev/null || {
    sudo apt-get install -y libmysqlclient-dev
}


cd /vagrant/ci_dashboard
python3.6 -m venv venv

# set DJANGO_SETTINGS_MODULE only if it's not already set in activate
grep -q -F "export DJANGO_SETTINGS_MODULE=$DJANGO_SETTINGS_MODULE" \
/vagrant/ci_dashboard/venv/bin/activate || \
echo "export DJANGO_SETTINGS_MODULE=$DJANGO_SETTINGS_MODULE" >> \
/vagrant/ci_dashboard/venv/bin/activate

source venv/bin/activate
pip3 install -U setuptools pip
pip3 install -r $PROJECT_REQUIREMENTS

cd /vagrant/ci_dashboard/src
python manage.py migrate --settings=$DJANGO_SETTINGS_MODULE
