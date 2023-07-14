#!/bin/bash
# tries to update all nodes and reboot them.
for i in {8..0}
do
  node="demo0$i"
  
  # Check if node is alive
  ping -c 1 -W 1 $node > /dev/null
  if [ $? -eq 0 ]; then
    echo "$node is alive, updating..."

    # Run the update, upgrade and reboot commands
    ssh -o ConnectTimeout=10 $node 'sudo apt update && sudo apt upgrade -y && sudo reboot' &
  else
    echo "$node is not responding, skipping..."
  fi
done

