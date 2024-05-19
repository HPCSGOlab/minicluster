#!/bin/bash

# Wrapper script to run the actual script as root
# Using logger to redirect the output to syslog with tag 'create_client_dirs'
/usr/bin/sudo /etc/dhcp/create_client_dirs.sh "$@" 2>&1 | logger -t create_client_dirs &
