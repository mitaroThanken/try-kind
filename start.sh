#!/bin/bash
set -e

WEB_UI_VERSION=v2.6.1

# create cluster
kind create cluster --config=config-cluster.yaml

# trap
trap "kind delete cluster" SIGINT

# contour
kubectl apply -f https://projectcontour.io/quickstart/contour.yaml
echo "Contour starting..."
kubectl wait deployment -n projectcontour contour --for condition=Available=True --timeout=2m
kubectl patch daemonsets -n projectcontour envoy -p '{"spec":{"template":{"spec":{"nodeSelector":{"ingress-ready":"true"},"tolerations":[{"key":"node-role.kubernetes.io/control-plane","operator":"Equal","effect":"NoSchedule"},{"key":"node-role.kubernetes.io/master","operator":"Equal","effect":"NoSchedule"}]}}}}'

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
