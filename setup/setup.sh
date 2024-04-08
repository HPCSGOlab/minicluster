#!/bin/bash -xe
# does unminimize have a yes flag?
yes | sudo unminimize

sudo systemctl disable docker.service docker.socket

sudo cp hosts /etc/
# turns off power saving mode that causes issues with remote access sometimes
sudo cp default-wifi-powersave-on.conf /etc/NetworkManager/conf.d/default-wifi-powersave-on.conf

    
sudo nmcli connection modify "Wired connection 1" ipv4.method manual ipv4.addresses "192.168.0.10/24"
sudo nmcli connection down "Wired connection 1"
sudo nmcli connection up "Wired connection 1"

sudo apt install iptables dnsmasq

# copy config files and then enable the daemons for reboot
sudo cp dnsmasq.conf /etc/dnsmasq.conf
sudo cp rules.v4 /etc/iptables/rules.v4
sudo cp dhcpd.conf /etc/dhcp/dhcpd.conf

sudo systemctl restart dnsmasq
sudo systemctl restart iptables
sudo systemctl restart isc-dhcp-server

sudo systemctl enable dnsmasq
sudo systemctl enable iptables
sudo systemctl enable isc-dhcp-server

# Enable IP forwarding
sudo bash -c 'echo 1 > /proc/sys/net/ipv4/ip_forward'

# Make IP forwarding setting persistent
sudo bash -c 'echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.conf'

# Load sysctl settings from the file to make sure they work
sudo sysctl -p
    
sudo blink1-tool --add_udev_rules

sudo reboot
