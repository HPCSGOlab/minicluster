#!/bin/bash

# Check if the user is root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root"
    exit 1
fi

# Enable IP forwarding
echo 1 > /proc/sys/net/ipv4/ip_forward

# Flush existing rules
iptables -F
iptables -t nat -F

# Default policy to drop 'everything' but our output to internet
iptables -P INPUT DROP
iptables -P OUTPUT ACCEPT

# Allow local-only connections
iptables -A INPUT -i lo -j ACCEPT

# Allow established connections (the responses to our outgoing traffic)
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow ssh
iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# Allow ICMP (ping) traffic
iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT

# Allow all outgoing connections
iptables -P OUTPUT ACCEPT

# Allow forwarding for our local network
iptables -P FORWARD ACCEPT

# Setup NAT for our local network
iptables -t nat -A POSTROUTING -o wlan0 -s 192.168.0.0/24 -j MASQUERADE

sudo sh -c 'iptables-save > /etc/iptables/rules.v4'
sudo sh -c 'ip6tables-save > /etc/iptables/rules.v6'

# Make IP forwarding setting persistent
echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.conf

# Load sysctl settings from the file to make sure they work
sudo sysctl -p

# Exit the script
exit 0

