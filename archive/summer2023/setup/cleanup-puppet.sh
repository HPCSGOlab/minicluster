#!/bin/bash -xe
#temporary script for cleaning up after testing puppet.sh

sudo apt purge '*puppet*' -y
sudo rm -rf /opt/puppetlabs/ /etc/puppetlabs/
rm puppet8-release-focal.deb

