#!/bin/bash
set -e
set -x

# versions
KIND_VERSION=v0.22.0
KUBECTL_VERSION=v1.29.3
HELM_VERSION=v3.14.4

# ~/.local/bin
LOCAL_BIN=${HOME}/.local/bin/
mkdir -p ${LOCAL_BIN}

# kind
if [ -e ${LOCAL_BIN}/kind ]; then
    rm ${LOCAL_BIN}/kind
fi
curl -LO "https://kind.sigs.k8s.io/dl/${KIND_VERSION}/kind-linux-amd64"
curl -LO "https://kind.sigs.k8s.io/dl/${KIND_VERSION}/kind-linux-amd64.sha256sum"
sha256sum --check kind-linux-amd64.sha256sum
mv kind-linux-amd64 kind
chmod +x ./kind
mv ./kind ${LOCAL_BIN}
rm kind-linux-amd64.sha256sum

# kubectl
if [ -e ${LOCAL_BIN}/kubectl ]; then
    rm ${LOCAL_BIN}/kubectl
fi
curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
curl -LO "https://dl.k8s.io/${KUBECTL_VERSION}/bin/linux/amd64/kubectl.sha256"
echo "$(cat kubectl.sha256) kubectl" | sha256sum --check
chmod +x ./kubectl
mv ./kubectl ${LOCAL_BIN}
rm ./kubectl.sha256

# helm
if [ -e ${LOCAL_BIN}/helm ]; then
    rm ${LOCAL_BIN}/helm
fi
curl -LO "https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz"
curl -LO "https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz.sha256sum"
sha256sum --check "helm-${HELM_VERSION}-linux-amd64.tar.gz.sha256sum"
tar -zxvf "helm-${HELM_VERSION}-linux-amd64.tar.gz"
mv linux-amd64/helm ${LOCAL_BIN}
rm -r linux-amd64
rm helm-${HELM_VERSION}-linux-amd64.tar.gz*
