#!/bin/bash
# Download git repo from bitbucket
git clone git@bitbucket.org:laltopi/ionogitlab-chef-repo.git chef-repo

# Create data bags ahead of sync-all
knife data bag create vhosts
# Put the sync-all in
mkdir -p .chef/plugins/knife
cp /vagrant/sync-all.rb .chef/plugins/knife
cd chef-repo
knife sync-all --all
# Create ssh keys to share
ssh-keygen -t rsa -b 2048 -f /home/vagrant/.ssh/chefws -N ""
