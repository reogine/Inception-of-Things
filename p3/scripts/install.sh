#!/bin/bash 


sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg

# install docker 
sudo apt-get install -y docker.io
sudo systemctl enable --now docker
sudo usermod -aG docker $USER

# install K3d 
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl

docker --version
k3d --version
kubectl version --client
