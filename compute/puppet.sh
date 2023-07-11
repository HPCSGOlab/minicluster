#!/bin/bash -xe
# this script is based on puppet 8 docs for focal ubuntu (jetson jetpack as of july 11 2023); may need update as versions change
# https://www.puppet.com/docs/puppet/8/install_puppet.html

DEB=puppet8-release-focal.deb
SERVER=demo00.uncc.edu

wget https://apt.puppet.com/${DEB}
sudo dpkg -i ./${DEB}
sudo apt-get update

if [[ `hostname` =~ 'demo00' ]]; then
    sudo apt-get -y install puppetserver
    sudo systemctl start puppetserver
    sudo systemctl enable puppetserver
    sudo sed -i '/\[server\]/a\autosign = true' /etc/puppetlabs/puppet/puppet.conf
    sudo /opt/puppetlabs/bin/puppet module install puppetlabs-stdlib
    sudo cp site.pp /etc/puppetlabs/code/environments/production/manifests/
    sudo systemctl restart puppetserver
else
    sudo cp hosts /etc/	
fi


sudo apt-get -y install puppet-agent
sudo /opt/puppetlabs/bin/puppet resource service puppet ensure=running enable=true
source /etc/profile.d/puppet-agent.sh
PUPPET=`which puppet`
sudo ${PUPPET} config set server ${SERVER} --section main
sudo ${PUPPET} ssl bootstrap
sleep 1
sudo ${PUPPET} ssl bootstrap

rm -f ./${DEB}
