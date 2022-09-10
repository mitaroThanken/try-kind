#!/bin/bash
set -e

METALLB_VERSION=v0.14.4

# Create cluster
kind create cluster --config=config-cluster.yaml

# Trap
trap "kind delete cluster" SIGINT

# Install MetalLB
# https://metallb.universe.tf/installation/

# Preparation
# https://metallb.universe.tf/installation/#preparation
kubectl get configmap kube-proxy -n kube-system -o yaml | \
sed -e "s/strictARP: false/strictARP: true/" | \
kubectl apply -f - -n kube-system

## Installation With Helm
## https://metallb.universe.tf/installation/#installation-with-helm
helm repo add metallb https://metallb.github.io/metallb
helm upgrade --install metallb metallb/metallb --create-namespace --namespace metallb-system

# Install istio
istioctl install --set profile=demo -y
kubectl label namespace default istio-injection=enabled

# Install dashboard
# https://github.com/kubernetes/dashboard/tree/master?tab=readme-ov-file#installation

## Add kubernetes-dashboard repository
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
## Deploy a Helm Release named "kubernetes-dashboard" using the kubernetes-dashboard chart
helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard --create-namespace --namespace kubernetes-dashboard

# Creating sample user
# https://github.com/kubernetes/dashboard/blob/master/docs/user/access-control/creating-sample-user.md
kubectl apply -f ./web-ui-sample-user.yaml

# Wait for available
echo "MetalLB starting..."
kubectl wait --namespace metallb-system \
                --for=condition=ready pod \
                --selector=app.kubernetes.io/instance=metallb \
                --timeout=90s
echo "Web UI starting..."
kubectl wait --namespace kubernetes-dashboard \
                --for=condition=ready pod \
                --selector=app.kubernetes.io/instance=kubernetes-dashboard \
                --timeout=90s

# Setup address pool used by loadbalancers
# https://kind.sigs.k8s.io/docs/user/loadbalancer/#setup-address-pool-used-by-loadbalancers
kubectl apply -f ./metallb-config.yaml

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
