

#!/bin/bash


# get ArgoCD password 
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# forward argoCD port 
kubectl port-forward -n argocd svc/argocd-server 8080:443

# forward playground port 
kubectl port-forward -n dev svc/playground 8888:8888
