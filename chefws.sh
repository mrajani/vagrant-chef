#!/bin/bash
#
# Configure chef workstation for Ubuntu/CentOS
#

chefserver="chefserver.iono.box"
chefdkpkg=/vagrant/chefdk-0.18.30-1.el7.x86_64.rpm
user=chefadmin
userpw=vagrant
username='Chef Admin'
email=chefadmin@iono.box
userpem=/vagrant/${user}.pem
org=iono-org
orgpem=/vagrant/${org}-validator.pem

dotchefdir=/home/vagrant/.chef
mkdir $dotchefdir; touch $dotchefdir/knife.rb
sudo chown -R vagrant:vagrant $dotchefdir

knife configure \
  --validation-client-name ${org}-validator \
  --validation-key ${orgpem} \
  --server-url https://${chefserver}/organizations/${org} \
  --repository /home/vagrant/chef-repo \
  --user ${user} \
  --key  ${userpem} \
  --config .chef/knife.rb -y
knife ssl fetch
knife ssl check

sudo knife client list
sudo knife user list
