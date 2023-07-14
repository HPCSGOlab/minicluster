#!/bin/bash

# List of nodes. Replace these with your actual node hostnames or IPs.
nodes=("demo00" "demo01" "demo02" "demo03" "demo04" "demo05" "demo06" "demo07" "demo08")

# The SSH command to run on each node.
command="echo Connected"

# Loop over each node.
for node in "${nodes[@]}"; do
  # Check if node is online
  ping -c 1 -W 1 $node &> /dev/null

  # If node is offline, skip it.
  if [ $? -ne 0 ]; then
    echo "Node $node is offline, skipping."
    continue
  fi

  # Loop over each other node.
  for other_node in "${nodes[@]}"; do
    # Don't connect to self.
    if [ "$node" != "$other_node" ]; then
      # Check if other node is online
      ping -c 1 -W 1 $other_node &> /dev/null

      # If other node is offline, skip it.
      if [ $? -ne 0 ]; then
        echo "Other node $other_node is offline, skipping."
        continue
      fi

      # Attempt to connect, run the puppet command and then run the echo command.
      yes | ssh -o StrictHostKeyChecking=no $node "sudo /opt/puppetlabs/bin/puppet agent -t && ssh -o StrictHostKeyChecking=no $other_node \"$command from $node to $other_node\""

      # Bootstrap the reverse connection. Node will SSH back to the originating node.
      yes | ssh -o StrictHostKeyChecking=no $node ssh -o StrictHostKeyChecking=no $other_node "sudo /opt/puppetlabs/bin/puppet agent -t && ssh -o StrictHostKeyChecking=no $node \"$command from $other_node to $node\""
    fi
  done
done

