#!/bin/bash

cd /vagrant/ci_dashboard/provision
. base_provision.sh

# add alias for quick work with virtualenv only if it's not already in ~/.bashrc
grep -q -F 'alias cool="source /vagrant/ci_dashboard/venv/bin/activate;cd /vagrant/ci_dashboard/src"' ~/.bashrc || \
echo 'alias cool="source /vagrant/ci_dashboard/venv/bin/activate;cd /vagrant/ci_dashboard/src"' >> ~/.bashrc && \
source ~/.bashrc
