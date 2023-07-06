#!/bin/bash

# The LAN IP and subnet mask.
LAN_IP="192.168.0.1"
LAN_NETMASK="255.255.255.0"
LAN_SUBNET="192.168.0.0/24"

# The wireless network name (SSID).
SSID="NinerWiFi-Guest"

# Configure eth0.
nmcli con add type ethernet ifname eth0 ip4 $LAN_IP/24
nmcli con mod eth0 ipv4.method manual ipv4.addresses $LAN_IP/24 ipv4.gateway $LAN_IP ipv4.dns "$LAN_IP"
nmcli con up eth0

# Configure wlan0.
nmcli dev wifi rescan
nmcli dev wifi connect $SSID ifname wlan0

# Set up the routing table.
ip route add default via $(nmcli -g IP4.GATEWAY dev show wlan0) dev wlan0 metric 100
ip route add $LAN_SUBNET dev eth0 metric 50

