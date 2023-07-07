#!/bin/bash

# Check if the user is root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root"
    exit 1
fi

sudo apt-get update
sudo apt-get install iptables-persistent
sudo apt-get install iptables

# Enable IP forwarding
echo 1 > /proc/sys/net/ipv4/ip_forward
echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# Flush existing rules
iptables -F
iptables -t nat -F

# Default policy to drop 'everything' but our output to internet
iptables -P FORWARD DROP
iptables -P INPUT DROP
iptables -P OUTPUT ACCEPT

# Allow established connections (the responses to our outgoing traffic)
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow ssh
iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# Allow traffic from our local network to the internet
iptables -A FORWARD -s 192.168.0.0/24 -j ACCEPT

# Allow established connections (the responses to our local network's traffic)
iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT

# Setup NAT
iptables -t nat -A POSTROUTING -s 192.168.0.0/24 -j MASQUERADE

sudo sh -c 'iptables-save > /etc/iptables/rules.v4'
sudo systemctl restart iptables.service

# Exit the script
exit 0

