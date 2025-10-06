#!/bin/bash

# Set kube context
kubectl config use-context k3d-mycluster

# Start port-forwarding Argo CD server
kubectl -n argocd port-forward svc/argocd-server 8080:443 > /dev/null 2>&1 &
PID_ARGOCD=$!

# Get Argo CD admin password
ARGOCD_PASS=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

echo ""
echo "🚀 Argo CD GUI: https://localhost:8080"
echo "   Username: admin"
echo "   Password: $ARGOCD_PASS"
echo ""
echo "⏳ Press Ctrl+C to stop..."

# Wait for port-forward
wait $PID_ARGOCD
