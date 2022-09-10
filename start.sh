#!/bin/bash
set -e

WEB_UI_VERSION=v2.6.1

# create cluster
kind create cluster --config=config-cluster.yaml

# trap
trap "kind delete cluster" SIGINT

# Web UI with sample user
kubectl apply -f "https://raw.githubusercontent.com/kubernetes/dashboard/${WEB_UI_VERSION}/aio/deploy/recommended.yaml"
kubectl apply -f ./web-ui-sample-user.yaml
echo "Web UI starting..."
kubectl wait deployment -n kubernetes-dashboard kubernetes-dashboard --for condition=Available=True --timeout=2m

# Started
echo "Web UI access token"
kubectl -n kubernetes-dashboard create token admin-user

echo "Dashboard available at http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/"

echo 'CTRL-C to delete cluster'
kubectl proxy
