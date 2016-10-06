#!/bin/bash
chefpkg=/vagrant/chef-server-core-12.9.1-1.el7.x86_64.rpm
user=chefadmin
userpw=vagrant
username='Chef Admin'
email=chefadmin@iono.box
userpem=/vagrant/${user}.pem
org=iono-org
orgpem=/vagrant/${org}-validator.pem

sudo yum check-update
sudo yum update -y && sudo yum install ntp crontabs -y

if [ -f $chefpkg ]; then
  sudo rpm -Uvh $chefpkg
else
  echo "Package $chefpkg not found"
  exit 1
fi

sudo chef-server-ctl reconfigure
# sudo chef-server-ctl test
sudo chef-server-ctl install chef-manage
sudo chef-server-ctl reconfigure
sudo chef-manage-ctl reconfigure --accept-license

sudo chef-server-ctl install opscode-reporting
sudo chef-server-ctl reconfigure
sudo opscode-reporting-ctl reconfigure

sudo chef-server-ctl user-create ${user} ${username} ${email} ${userpw} \
  -f ${userpem}
sudo chef-server-ctl org-create ${org} Iono_Org -a $user \
  -f ${orgpem}
