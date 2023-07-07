#!/bin/bash

# Name of the connection/device
CONN_NAME="Wired connection 1"
DEV_NAME="eth0"

# Check if the user is root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root"
    exit 1
fi

# Set connection to use DHCP
nmcli con mod "$CONN_NAME" ipv4.method auto
nmcli con down "$CONN_NAME" && nmcli con up "$CONN_NAME"

# Wait a bit to make sure DHCP negotiation has completed
sleep 5

# Remove all existing routes
ip route flush table main

# Set the default gateway
ip route add default via 192.168.0.10 dev "$DEV_NAME"

# Exit the script
exit 0

