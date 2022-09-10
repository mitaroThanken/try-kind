#!/bin/bash
set -e

WEB_UI_VERSION=v2.6.1

# create cluster
kind create cluster --config=config-cluster.yaml

# trap
trap "kind delete cluster" SIGINT

# istio
istioctl install --set profile=demo -y
kubectl label namespace default istio-injection=enabled
echo "Istio starting..."
kubectl wait deployment -n istio-system istio-ingressgateway --for condition=Available=True --timeout=2m
kubectl patch deployment -n istio-system istio-ingressgateway -p '{"spec":{"template":{"spec":{"containers":[{"name":"istio-proxy","ports":[{"containerPort":8080,"hostPort":80,"name":"http2","protocol":"TCP"},{"containerPort":8443,"hostPort":443,"name":"https","protocol":"TCP"}]}],"nodeSelector":{"ingress-ready":"true"},"tolerations":[{"key":"node-role.kubernetes.io/control-plane","operator":"Equal","effect":"NoSchedule"},{"key":"node-role.kubernetes.io/master","operator":"Equal","effect":"NoSchedule"}]}}}}'

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
