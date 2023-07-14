#!/bin/bash -xe
# this script is based on puppet 8 docs for focal ubuntu (jetson jetpack as of july 11 2023); may need update as versions change
# https://www.puppet.com/docs/puppet/8/install_puppet.html

DEB=puppet8-release-focal.deb
SERVER=demo00.uncc.edu

# declare an associative array
declare -A mac_host_map

# populate the array with MAC:hostname pairs
mac_host_map=(
  ["48:b0:2d:bc:8c:9c"]="demo00"
  ["48:b0:2d:e8:c6:95"]="demo01"
  ["48:b0:2d:eb:c7:74"]="demo02"
  ["48:b0:2d:bc:8d:be"]="demo03"
  ["48:b0:2d:eb:c8:b4"]="demo04"
  ["48:b0:2d:bc:8e:dd"]="demo05"
  ["48:b0:2d:eb:c9:c2"]="demo06"
  ["48:b0:2d:e8:c7:08"]="demo07"
  ["48:b0:2d:bc:8e:b7"]="demo08"
)

# get the MAC address of eth0
mac_addr=$(ip link show eth0 | awk '/ether/ {print $2}')

# look up the MAC address in the array
new_hostname="${mac_host_map[$mac_addr]}"

if [ -z "$new_hostname" ]; then
  echo "No hostname found for MAC $mac_addr"
else
  echo "Setting hostname to $new_hostname for MAC $mac_addr"
  echo "You may be asked for your password for sudo command:"
  sudo hostnamectl set-hostname $new_hostname
fi

# does unminimize have a yes flag?
yes | sudo unminimize

systemctl disable docker.service docker.socket

sudo cp hosts /etc/	
ssh-keyscan ${SERVER} >> ~/.ssh/known_hosts

wget https://apt.puppet.com/${DEB}
sudo dpkg -i ./${DEB}
sudo apt-get update

if [[ `hostname` =~ 'demo00' ]]; then
    
    sudo apt install iptables dnsmasq puppetserver -y
    sudo systemctl stop docker.service docker.socket

    sudo cp dnsmasq.conf /etc/dnsmasq.conf
    sudo cp rules.v4 /etc/iptables/rules.v4
    sudo cp dhcpd.conf /etc/dhcp/dhcpd.conf
    sudo cp site.pp /etc/puppetlabs/code/environments/production/manifests/

    sudo systemctl restart dnsmasq
    sudo systemctl restart iptables
    sudo systemctl restart isc-dhcp-server
    sudo systemctl restart puppetmaster

    # Enable IP forwarding
    sudo bash -c 'echo 1 > /proc/sys/net/ipv4/ip_forward'

    # Make IP forwarding setting persistent
    sudo bash -c 'echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.conf'

    # Load sysctl settings from the file to make sure they work
    sudo sysctl -p
    
    # configure puppet
    sudo systemctl start puppetserver
    sudo systemctl enable puppetserver
    sudo sed -i '/\[server\]/a\autosign = true' /etc/puppetlabs/puppet/puppet.conf
    sudo /opt/puppetlabs/bin/puppet module install puppetlabs-stdlib
    sudo cp site.pp /etc/puppetlabs/code/environments/production/manifests/

    sudo `which puppet` module install puppetlabs-sshkeys_core
    sudo `which puppet` module install puppetlabs-stdlib
    sudo systemctl restart puppetserver
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
