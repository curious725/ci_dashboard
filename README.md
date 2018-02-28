# CI dashboard
> Main goal is to visualize data from csv file and build charts from this data to show to the user.

Currently available here: http://ci-dashboard.dev.immo/

Backend: Django & Django REST Framework creates API endpoint where is sent information about all builds from database in JSON format.

Frontend: Javascript parses this data and builds charts with Chart.js.


# Algorithm we used to detect outliers in failed builds
An outlier is an observation that lies an abnormal distance from other values in a random sample from a population. 

To detect outliers we use a method described by Moore and McCabe.
This method gives more strict definition of outlier as a point which falls more than 1.5 times the interquartile range above the third quartile or below the first quartile.
According to this method, we need to find for our sorted dataset:
- the first quartile         Q1
- the third quartile         Q3
- interquartile range        IQR = Q3 - Q1
- lower outlier boundary     = Q1 - 1.5 * IQR      
- upper outlier boundary     = Q3 + 1.5 * IQR       
  Low outliers are below lower outlier boundary.
  High outliers are above upper outlier boundary.

In our application we are interested only in high outliers - we want to track the number of failed builds that is bigger than normal.


## Installation

 * Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
 * Install [VirtualBox Oracle VM VirtualBox Extension Pack](https://www.virtualbox.org/wiki/Downloads)
 * Install [Vagrant](https://www.vagrantup.com/downloads.html)
 * Install Vagrant plugins:
 ```sh
 * vagrant plugin install vagrant-json-config
 * vagrant plugin install vagrant-rsync-back
 * vagrant plugin install vagrant-digitalocean
```

## Run Locally

* `git clone` this repository:

* Set configuration for the project:
```bash
 $ cd ci_dashboard
 $ cp sample.secrets.json secrets.json
```
Put your own values in secrets.json file. 

* To start development run on your local machine
(inside our project folder ci_dashboard)
```bash
 $ cd ci_dashboard
 $ vagrant up dev
  ```
  Now run inside vagrant machine:
 ```bash
 $ vagrant ssh dev
 $ cd /vagrant/ci_dashboard/
 $ source venv/bin/activate
 $ cd src
 $ python manage.py runserver 0.0.0.0:8000
 ```
 * Navigate to [http://localhost:8000/](http://localhost:8888/) to access server.
 
 ## Configuration of this project
 We have only one configuration file - secrets.json.
 You can check sample.secrets.json file as an example.To configure the project you can copy this file into secrets.json and put your own values.

Also this project is configured with strict division of DEVELOPMENT and PRODUCTION environments configurations
For requirements (ci_dashboard/requirements/) we have:
- base.txt  - common dependencies
- dev.txt   - local development dependencies
- prod.txt  - dependencies specific only to production

For provision scripts (ci_dashboard/provision/):
base_provision.sh, dev_provision.sh,prod_provision.sh.
For Django configuration settings (ci_dashboard/src/core/settings/):
base.py, dev.py,prod.py

