#!/bin/bash
# this script sets the default runlevel to 3 to avoid starting up a desktop environment and wasting a large portion of memory/gpu time

# Define the nodes
nodes=(demo01 demo02 demo03 demo04 demo05 demo06 demo07 demo08)

# Iterate over nodes
for node in "${nodes[@]}"; do
    echo "Checking connection to $node..."
    # Ping the node to check if it's online
    if ping -c 1 -W 1 "$node" >/dev/null; then
        echo "$node is up"
        ssh -o ConnectTimeout=5 "$node" "/opt/puppetlabs/bin/puppet agent -t"
    else
        echo "$node is down"
    fi
done

