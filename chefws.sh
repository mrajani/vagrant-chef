#!/bin/bash
#
# Configure chef workstation for Ubuntu/CentOS
#

chefserver="chefserver.iono.box"
user=chefadmin
username='Chef Admin'
email=chefadmin@iono.box
userpem=/vagrant/${user}.pem
org=iono-org
orgpem=/vagrant/${org}-validator.pem

dotchefdir=/home/vagrant/.chef
mkdir $dotchefdir; touch $dotchefdir/knife.rb
cp /vagrant/knife.rb ${dotchefdir}/knife.rb
sudo chown -R vagrant:vagrant $dotchefdir

knife ssl fetch
knife ssl check

sudo knife client list
sudo knife user list
