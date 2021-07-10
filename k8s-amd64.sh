#!/bin/bash

# Missing dep
apt-get update
apt-get install -y apt-transport-https ca-certificates curl

# Add k8s repo and signing key
curl -fsSLo /etc/apt/trusted.gpg.d/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/etc/apt/trusted.gpg.d/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list

# Isntalling k8s
apt-get update
apt-get install -y kubectl
