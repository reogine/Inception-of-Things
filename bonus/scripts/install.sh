#!/bin/bash

set -euo pipefail

packages=(ca-certificates curl gnupg)


source $(dirname "$0")/logger.sh

export DEBIAN_FRONTEND=noninteractive

info "Updating package lists..."
apt-get update >/dev/null 2>&1

info "Installing required packages..."

apt-get install -y "${packages[@]}" >/dev/null 2>&1

info "Installing docker.."
if ! command -v docker >/dev/null 2>&1; then
    info "Installing Docker..."
    apt-get install -y docker.io >/dev/null 2>&1
    success "Docker installed."
else
    info "Docker is already installed."
fi

info "Installing k3d..."
if ! command -v k3d >/dev/null 2>&1; then
    info "Installing k3d..."
    curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash >/dev/null 2>&1
    success "k3d installed."
else
    info "k3d is already installed."
fi

info "Installing kubectl..."
if ! command -v kubectl >/dev/null 2>&1; then
    info "Installing kubectl..."
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" >/dev/null 2>&1
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm -f kubectl
    success "kubectl installed."
else
    info "kubectl is already installed."
fi

info "Installing helm..."
if ! command -v helm >/dev/null 2>&1; then
    info "Installing helm..."
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash >/dev/null 2>&1
    success "helm installed."
else
    info "helm is already installed."
fi

success "All installations completed successfully."