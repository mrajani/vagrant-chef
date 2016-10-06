#!/bin/bash
#
# Install Chef Client for Ubuntu/CentOS
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

sudo yum check-update
sudo yum update -y && sudo yum install ntp crontabs -y

echo Installing Chef Client
if [ -f $chefdkpkg ]; then
  sudo rpm -Uvh $chefdkpkg
else
  echo "Package $chefdkpkg not found"
  exit 1
fi

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

# debugging plural sight
# chef verify
# chef gem list chef-config
# chef gem list chef-config -ra
# knife cookbook create lab-linux
# chef generate repo chef-repo
# chef generate cookbook sample-cookbook
# berks
# berks install
# berks upload -no-ssl-verify
# knife node run_list add a49 'role[lab-linux]'
# knife node run_list remove a49 'role[lab-linux]'
