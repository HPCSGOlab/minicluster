#!/bin/bash -xe
# this script is based on puppet 8 docs for focal ubuntu (jetson jetpack as of july 11 2023); may need update as versions change
# https://www.puppet.com/docs/puppet/8/install_puppet.html

DEB=puppet8-release-focal.deb
SERVER=demo00

wget https://apt.puppet.com/${DEB}
sudo dpkg -i ./${DEB}

sudo apt-get update

if [[ `hostname` =~ 'demo00' ]]; then
    sudo apt-get -y install puppetserver
    sudo systemctl start puppetserver
    sudo systemctl enable puppetserver
    sed -i '/\[server\]/a\ autosign = true' /etc/puppetlabs/puppet/puppet.conf
    sudo systemctl restart puppetserver 
fi

sudo apt-get -y install puppet-agent
sudo /opt/puppetlabs/bin/puppet resource service puppet ensure=running enable=true
source /etc/profile.d/puppet-agent.sh
sudo -E puppet config set server ${SERVER} --section main
sudo -E puppet ssl bootstrap
sleep 1
puppet ssl bootstrap