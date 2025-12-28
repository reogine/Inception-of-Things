#!/usr/bin/env bash
set -euo pipefail

CLUSTER_NAME="${CLUSTER_NAME:-iot}"
ARGO_NS="argocd"
DEV_NS="dev"

echo "[1/4] Delete Argo CD Application (if exists)..."
kubectl get application playground -n "$ARGO_NS" >/dev/null 2>&1 \
  && kubectl delete application playground -n "$ARGO_NS" \
  || echo "Application not found."

echo "[2/4] Delete namespaces (argocd, dev)..."
kubectl get ns "$ARGO_NS" >/dev/null 2>&1 \
  && kubectl delete ns "$ARGO_NS" \
  || echo "Namespace $ARGO_NS not found."

kubectl get ns "$DEV_NS" >/dev/null 2>&1 \
  && kubectl delete ns "$DEV_NS" \
  || echo "Namespace $DEV_NS not found."

echo "Waiting for namespaces to terminate..."
sleep 5

echo "[3/4] Delete k3d cluster (if exists)..."
if k3d cluster list | awk '{print $1}' | grep -qx "$CLUSTER_NAME"; then
  k3d cluster delete "$CLUSTER_NAME"
else
  echo "Cluster '$CLUSTER_NAME' not found."
fi

echo "[4/4] Cleanup complete."
echo
echo "You can now re-run:"
echo "  ./p3/scripts/bootstrap.sh"

