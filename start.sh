#!/bin/bash
set -e

METALLB_VERSION=v0.13.5

# Create cluster
kind create cluster --config=config-cluster.yaml

# Trap
trap "kind delete cluster" SIGINT

# Install MetalLB
kubectl get configmap kube-proxy -n kube-system -o yaml | \
sed -e "s/strictARP: false/strictARP: true/" | \
kubectl apply -f - -n kube-system
kubectl apply -f "https://raw.githubusercontent.com/metallb/metallb/${METALLB_VERSION}/config/manifests/metallb-native.yaml"

# Install dashboard
# https://github.com/kubernetes/dashboard/tree/master?tab=readme-ov-file#installation

# Add kubernetes-dashboard repository
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
# Deploy a Helm Release named "kubernetes-dashboard" using the kubernetes-dashboard chart
helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard --create-namespace --namespace kubernetes-dashboard

# Creating sample user
# https://github.com/kubernetes/dashboard/blob/master/docs/user/access-control/creating-sample-user.md
kubectl apply -f ./web-ui-sample-user.yaml

# Wait for available
echo "MetalLB starting..."
kubectl wait deployment -n metallb-system controller --for condition=Available=True --timeout=2m
echo "Web UI starting..."
kubectl wait deployment -n kubernetes-dashboard kubernetes-dashboard-kong --for condition=Available=True --timeout=1m

# Getting a Bearer Token for ServiceAccount
# https://github.com/kubernetes/dashboard/blob/master/docs/user/access-control/creating-sample-user.md#getting-a-bearer-token-for-serviceaccount
echo "Web UI access token"
kubectl -n kubernetes-dashboard create token admin-user

# Guide
echo "Dashboard available at https://localhost:8443"
echo 'CTRL-C to delete cluster'

# Accessing Dashboard
# https://github.com/kubernetes/dashboard/blob/master/docs/user/accessing-dashboard/README.md
kubectl -n kubernetes-dashboard port-forward svc/kubernetes-dashboard-kong-proxy 8443:443
