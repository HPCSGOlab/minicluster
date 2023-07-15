#!/bin/bash

# Define the list of files to check.
declare -A files
files=(
    ["/etc/dhcp/dhcpd.conf"]="dhcpd.conf"
    ["/etc/dnsmasq.conf"]="dnsmasq.conf"
    ["/etc/puppetlabs/code/environments/production/manifests/site.pp"]="site.pp"
    ["/etc/puppetlabs/puppet/puppet.conf"]="puppet.conf"
    ["/etc/iptables/rules.v4"]="rules.v4"
    ["/etc/hosts"]="hosts"
)

# Get the directory the script is running from.
scriptDir=$(dirname "$(readlink -f "$0")")

# Check each file.
for filePath in "${!files[@]}"; do
    fileName=${files[$filePath]}
    if ! diff -q "$filePath" "$scriptDir/$fileName" > /dev/null 2>&1; then
        echo "Differences detected in $fileName, updating backup..."
        cp "$filePath" "$scriptDir/$fileName"
    fi
done

