#!/bin/bash
user=chefadmin
userpw=vagrant
username='Chef Admin'
email=chefadmin@iono.box
userpem=/vagrant/${user}.pem
org=iono-org
orgpem=/vagrant/${org}-validator.pem

chefpkg=/vagrant/chef-server-core-12.9.1-1.el7.x86_64.rpm
# Install key to verify package
sudo rpm --import https://downloads.chef.io/packages-chef-io-public.key
# Copy chef-repo
sudo cp /vagrant/chef-stable-7.repo /etc/yum.repos.d/chef-stable.repo
echo "Running yum update install ntp yum-utils crontabs, may take upto 4 mins"
sudo yum update -q -y
sudo yum install -q -y ntp yum-utils crontabs tree
# Format the package name in rpm
RPM=$(repoquery --qf="%{name}-%{version}-%{release}.%{arch}" chef-server-core)
RPM="${RPM}.rpm"

if [ -f /vagrant/${RPM} ]; then
   echo "RPM ${RPM} exists, installing"
   RPM="/vagrant/${RPM}"
else
   echo "Downloading ${RPM}"
   yum install -y --downloadonly --downloaddir=. chef-server-core
   echo "Installing ${RPM}"
fi

sudo rpm -iv $RPM
sudo chef-server-ctl reconfigure
# sudo chef-server-ctl test
sudo chef-server-ctl install chef-manage
sudo chef-server-ctl reconfigure
sudo chef-manage-ctl reconfigure --accept-license

sudo chef-server-ctl install opscode-reporting
sudo chef-server-ctl reconfigure
sudo opscode-reporting-ctl reconfigure --accept-license

sudo chef-server-ctl user-create ${user} ${username} ${email} ${userpw} \
  -f ${userpem}
sudo chef-server-ctl org-create ${org} Iono_Org -a $user \
  -f ${orgpem}
