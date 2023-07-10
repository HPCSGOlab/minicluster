#!/bin/bash

# Check if the user is root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root"
    exit 1
fi


apt install iptables puppetmaster dnsmasq
systemctl disable docker.service docker.socket
systemctl stop docker.service docker.socket

cp dnsmasq.conf /etc/dnsmasq.conf
cp rules.v4 /etc/iptables/rules.v4
cp dhcpd.conf /etc/dhcp/dhcpd.conf

sudo systemctl restart dnsmasq
sudo systemctl restart iptables
sudo systemctl restart isc-dhcp-server

# Enable IP forwarding
echo 1 > /proc/sys/net/ipv4/ip_forward

# Make IP forwarding setting persistent
echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.conf

# Load sysctl settings from the file to make sure they work
sysctl -p

