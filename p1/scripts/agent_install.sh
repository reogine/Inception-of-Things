#!/bin/bash

# Set the colors
GREEN="\033[32m"
RED="\033[31m"
RESET="\033[0m"

# 1. Wait for the token (Just in case Worker is faster than Master)
while [ ! -f /vagrant/token.env ]; do
  echo "Waiting for Master Token..."
  sleep 2
done

# 2. Set environment variables
# We use the token from the shared folder
TOKEN=$(cat /vagrant/token.env)
export INSTALL_K3S_EXEC="agent --server https://192.168.56.110:6443 --token ${TOKEN} --node-ip=192.168.56.111"

# 3. Install K3s (Agent Mode)
if curl -sfL https://get.k3s.io | sh -; then
    echo -e "${GREEN}K3s WORKER installation SUCCEEDED${RESET}"
else
    echo -e "${RED}K3s WORKER installation FAILED${RESET}"
    exit 1
fi

# 4. Cleanup (Optional: remove token for security)
rm /vagrant/token.env
