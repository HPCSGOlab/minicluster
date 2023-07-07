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
iptables -P FORWARD DROP
iptables -P INPUT DROP
iptables -P OUTPUT ACCEPT

# Allow established connections (the responses to our outgoing traffic)
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow ssh
iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# Allow ICMP (ping) traffic
iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT

# Allow traffic from our local network to the internet
iptables -A FORWARD -s 192.168.0.0/24 -j ACCEPT

# Allow established connections (the responses to our local network's traffic)
iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT

# Setup NAT
iptables -t nat -A POSTROUTING -s 192.168.0.0/24 -j MASQUERADE

# Make IP forwarding setting persistent
echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.conf

# Load sysctl settings from the file to make sure they work
sudo sysctl -p

# Exit the script
exit 0

