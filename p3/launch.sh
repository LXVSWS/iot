#!/bin/bash

# Set kube context
kubectl config use-context k3d-mycluster

# Start port-forwarding Argo CD server
kubectl -n argocd port-forward svc/argocd-server 8080:443 &
PID_ARGOCD=$!

# Start port-forwarding app service
kubectl -n dev port-forward svc/app 8888:80 &
PID_APP=$!

# Get Argo CD admin password
ARGOCD_PASS=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

echo ""
echo "🎉 Argo CD GUI: https://localhost:8080"
echo "   Username: admin"
echo "   Password: $ARGOCD_PASS"
echo ""
echo "🚀 App: http://localhost:8888"
echo ""
echo "⏳ Press Ctrl+C to stop..."

# Wait for both port-forwards
wait $PID_ARGOCD
wait $PID_APP
