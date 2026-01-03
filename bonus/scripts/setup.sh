#!/bin/bash

set -euo pipefail

source $(dirname "$0")/logger.sh

CLUSTER_NAME="bonus-iot-cluster"
NAMESPACES=("argocd" "gitlab" "dev")

# Set up Docker service
info "Setting up Docker service..."
if  command -v docker >/dev/null 2>&1
then
    systemctl enable --now docker
    success "Docker service is enabled and started."
else
    error "Docker is not installed."
    exit 1
fi

# Set up k3d cluster
info "Setting up k3d cluster..."
if command -v k3d >/dev/null 2>&1
then
    if k3d cluster list | grep -q "^${CLUSTER_NAME} "; then
        info "k3d cluster '${CLUSTER_NAME}' already exists. Skipping creation."
    else
        k3d cluster create "${CLUSTER_NAME}" \
            --api-port 6550 \
            -p "8081:30081@server:0" \
            -p "8082:80@loadbalancer" \
            -p "8083:30083@server:0" \
            --agents 2 \
            --wait >/dev/null 2>&1
        success "k3d cluster '${CLUSTER_NAME}' created successfully."
    fi
else
    error "k3d is not installed."
    exit 1
fi

# Create namespaces
info "Creating k3d namespaces..."
for ns in "${NAMESPACES[@]}"; do
    if kubectl get namespace "$ns" >/dev/null 2>&1; then
        info "Namespace '$ns' already exists. Skipping creation."
    else
        kubectl create namespace "$ns" >/dev/null 2>&1
        success "Namespace '$ns' created successfully."
    fi
done

# Install Argo CD
info "Installing Argo CD in the cluster..."
if kubectl get deploy -n argocd argocd-server >/dev/null 2>&1; then
    info "Argo CD appears to be already installed. Skipping installation."
else
    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml >/dev/null 2>&1
    kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort", "ports": [{"port": 80, "nodePort": 30081}, {"port": 443, "nodePort": 30443}]}}' >/dev/null 2>&1
    info "Waiting for Argo CD components to be ready..."
    kubectl wait --for=condition=Available deploy/argocd-server -n argocd --timeout=300s >/dev/null 2>&1
    kubectl wait --for=condition=Ready pods -n argocd --all --timeout=300s >/dev/null 2>&1
    success "Argo CD installed successfully in the 'argocd' namespace."
fi

# Apply Argo CD Application config
if kubectl get application -n argocd iot-app >/dev/null 2>&1; then
    info "Argo CD Application 'iot-app' already exists. Skipping application."
else
    info "Applying Argo CD Application config..."
    kubectl apply -n argocd -f ./confs/argocd/application.yaml >/dev/null 2>&1
    success "Argo CD Application config applied successfully."
fi

# Install GitLab
if kubectl get deploy -n gitlab gitlab-webservice-default >/dev/null 2>&1; then
    info "GitLab appears to be already installed. Skipping installation."
else    
    info "Installing GitLab in the cluster..."
    helm repo add gitlab https://charts.gitlab.io/ >/dev/null 2>&1
    helm repo update >/dev/null 2>&1
    helm upgrade --install gitlab gitlab/gitlab \
        -n gitlab \
        -f ./confs/gitlab/values.yaml \
        --wait >/dev/null 2>&1
    success "GitLab installed successfully in the 'gitlab' namespace."
fi

success "Setup completed successfully."
echo ""

# Retrieve credentials
ARGOCD_PASS=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
GITLAB_PASS=$(kubectl -n gitlab get secret gitlab-gitlab-initial-root-password -o jsonpath="{.data.password}" | base64 -d)

# Display services table
services_table --start
services_table "ArgoCD" "http://localhost:18081" "admin" "$ARGOCD_PASS"
services_table "GitLab" "http://gitlab.localhost:18082" "root" "$GITLAB_PASS"
services_table "App" "http://localhost:18083" "" ""
services_table --end
