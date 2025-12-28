#!/usr/bin/env bash
set -euo pipefail

CLUSTER_NAME="${CLUSTER_NAME:-iot}"
ARGO_NS="argocd"
DEV_NS="dev"

command -v docker >/dev/null
command -v k3d >/dev/null
command -v kubectl >/dev/null

# Ensure docker works without sudo
docker ps >/dev/null

echo "[1/6] Create k3d cluster (if missing)..."
if ! k3d cluster list | awk '{print $1}' | grep -qx "$CLUSTER_NAME"; then
  k3d cluster create "$CLUSTER_NAME" --servers 1 --agents 1
else
  echo "Cluster '$CLUSTER_NAME' already exists."
fi

echo "[2/6] Wait for nodes..."
kubectl wait --for=condition=Ready nodes --all --timeout=180s

echo "[3/6] Create namespaces..."
kubectl get ns "$ARGO_NS" >/dev/null 2>&1 || kubectl create ns "$ARGO_NS"
kubectl get ns "$DEV_NS"  >/dev/null 2>&1 || kubectl create ns "$DEV_NS"

echo "[4/6] Install Argo CD (if missing)..."
# If you prefer a pinned local copy, apply your confs/argocd/install.yaml instead of URL.
if ! kubectl get deploy -n "$ARGO_NS" argocd-server >/dev/null 2>&1; then
  kubectl apply -n "$ARGO_NS" -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
else
  echo "Argo CD appears installed already."
fi

echo "[5/6] Wait for Argo CD pods..."
kubectl wait --for=condition=Available deploy/argocd-server -n "$ARGO_NS" --timeout=300s || true
kubectl wait --for=condition=Ready pods -n "$ARGO_NS" --all --timeout=300s || true

echo "[6/6] Apply Argo CD Application (GitOps app)..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

kubectl apply -f "$ROOT_DIR/confs/argocd/app.yaml"

echo "Bootstrap done."
echo
echo "Useful checks:"
echo "  kubectl get ns"
echo "  kubectl get pods -n argocd"
echo "  kubectl get pods -n dev"

