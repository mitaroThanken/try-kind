#!/bin/bash
set -e

METALLB_VERSION=v0.13.5
WEB_UI_VERSION=v2.6.1

# create cluster
kind create cluster --config=config-cluster.yaml

# trap
trap "kind delete cluster" SIGINT

# MetalLB
kubectl get configmap kube-proxy -n kube-system -o yaml | \
sed -e "s/strictARP: false/strictARP: true/" | \
kubectl apply -f - -n kube-system
kubectl apply -f "https://raw.githubusercontent.com/metallb/metallb/${METALLB_VERSION}/config/manifests/metallb-native.yaml"

# Web UI with sample user
kubectl apply -f "https://raw.githubusercontent.com/kubernetes/dashboard/${WEB_UI_VERSION}/aio/deploy/recommended.yaml"
kubectl apply -f ./web-ui-sample-user.yaml

# Wait
echo "MetalLB starting..."
kubectl wait deployment -n metallb-system controller --for condition=Available=True --timeout=2m
echo "Web UI starting..."
kubectl wait deployment -n kubernetes-dashboard kubernetes-dashboard --for condition=Available=True --timeout=2m

# Started
echo "Please configure MetalLB. See metallb-config.yaml."
echo "Web UI access token"
kubectl -n kubernetes-dashboard create token admin-user

echo "Dashboard available at http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/"

echo 'CTRL-C to delete cluster'
kubectl proxy
