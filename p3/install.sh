#!/bin/bash

# Install k3d
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && rm kubectl

# Create cluster
k3d cluster create mycluster

# Set kube context
kubectl config use-context k3d-mycluster

# Create namespaces
kubectl create namespace argocd
kubectl create namespace dev

# Install Argo CD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for Argo CD server to be ready
kubectl -n argocd wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server --timeout=120s

# Apply Argo CD Application manifest
kubectl apply -f argo.yaml

# Start port-forwarding Argo CD server (in background)
kubectl -n argocd port-forward svc/argocd-server 8080:443 >/dev/null 2>&1 &

# Get Argo CD admin password
ARGOCD_PASS=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

echo ""
echo "🎉 Argo CD GUI is accessible at: https://localhost:8080"
echo "    Username: admin"
echo "    Password: $ARGOCD_PASS"
echo ""

# Start port-forwarding the app service in the background
kubectl -n dev port-forward svc/app 8888:80 >/dev/null 2>&1 &

echo "🚀 App is accessible at: http://localhost:8888"
