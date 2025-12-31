#!/bin/bash

set -euo pipefail

packages=(ca-certificates curl gnupg)


source $(dirname "$0")/logger.sh

export DEBIAN_FRONTEND=noninteractive

info "Updating package lists..."
apt-get update >/dev/null 2>&1

info "Installing required packages..."

# Install all required packages
apt-get install -y "${packages[@]}" >/dev/null 2>&1

# Install docker if not installed
if ! command -v docker >/dev/null 2>&1; then
    info "Installing Docker..."
    apt-get install -y docker.io >/dev/null 2>&1
    success "Docker installed."
else
    info "Docker is already installed."
fi

# Install k3d if not installed
if ! command -v k3d >/dev/null 2>&1; then
    info "Installing k3d..."
    curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash >/dev/null 2>&1
    success "k3d installed."
else
    info "k3d is already installed."
fi

# Install kubectl if not installed
if ! command -v kubectl >/dev/null 2>&1; then
    info "Installing kubectl..."
    curl -LO -s "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" >/dev/null 2>&1
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm -f kubectl
    success "kubectl installed."
else
    info "kubectl is already installed."
fi

# Install helm if not installed
if ! command -v helm >/dev/null 2>&1; then
    info "Installing helm..."
    curl -s https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash >/dev/null 2>&1
    success "helm installed."
else
    info "helm is already installed."
fi

success "All installations completed successfully."