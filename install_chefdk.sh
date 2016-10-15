#!/bin/bash
#
# Install Chef DK for CentOS
#

sudo rpm --import https://downloads.chef.io/packages-chef-io-public.key
# Copy chef-repo
sudo cp /vagrant/chef-stable-7.repo /etc/yum.repos.d
echo "Running yum update install ntp yum-utils crontabs, may take upto 4 mins"
sudo yum update -q -y
sudo yum install -q -y ntp yum-utils crontabs tree
# Format the package name in rpm
RPM=$(repoquery --qf="%{name}-%{version}-%{release}.%{arch}" chefdk)
RPM="${RPM}.rpm"

if [ -f /vagrant/${RPM} ]; then
   echo "RPM ${RPM} exists, installing"
   RPM="/vagrant/${RPM}"
else
   echo "Downloading ${RPM}"
   yum install -y --downloadonly --downloaddir=. chefdk
   echo "Installing ${RPM}"
fi
sudo rpm -iv $RPM
