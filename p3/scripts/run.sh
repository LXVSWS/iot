#!/bin/bash

# Set kube context
kubectl config use-context k3d-mycluster

# Start port-forwarding app service
kubectl -n dev port-forward svc/app 8888:80 &
PID_APP=$!

echo ""
echo "🚀 App: http://localhost:8888"
echo ""
echo "⏳ Press Ctrl+C to stop..."

# Wait for port-forward
wait $PID_APP
