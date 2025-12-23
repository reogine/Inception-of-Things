#!/bin/bash

# Set the colors
GREEN="\033[32m"
RED="\033[31m"
RESET="\033[0m"

# 1. Set environment variables for K3s
export INSTALL_K3S_EXEC="--write-kubeconfig-mode=644 --tls-san midfathS --node-ip 192.168.56.110 --bind-address=192.168.56.110 --advertise-address=192.168.56.110"

# 2. Install K3s (Master Mode)
if curl -sfL https://get.k3s.io | sh -; then
    echo -e "${GREEN}K3s MASTER installation SUCCEEDED${RESET}"
else
    echo -e "${RED}K3s MASTER installation FAILED${RESET}"
    exit 1
fi
