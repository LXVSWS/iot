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

echo "✅ K3d & Argo CD installed, namespaces created"
echo "⏳ Waiting for Argo CD server to be ready..."

kubectl -n argocd wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server --timeout=120s

# Start port-forwarding Argo CD server (in background)
echo "🚪 Starting port-forward for Argo CD UI at https://localhost:8080 ..."
kubectl -n argocd port-forward svc/argocd-server 8080:443 >/dev/null 2>&1 &

# Get Argo CD admin password
ARGOCD_PASS=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

echo ""
echo "🎉 Argo CD UI is accessible at: https://localhost:8080"
echo "    Username: admin"
echo "    Password: $ARGOCD_PASS"
echo ""
