#!/bin/bash

# Missing dep for downloading things with curl
apt-get update
apt-get install -y apt-transport-https ca-certificates curl


# Enabling rooting for wireguard VPN and k8s
modprobe overlay
modprobe br_netfilter
sysctl -w net.ipv4.ip_forward=1
sysctl -w net.ipv6.conf.all.forwarding=1
sysctl -w net.bridge.bridge-nf-call-ip6tables=1
sysctl -w net.bridge.bridge-nf-call-iptables=1
sysctl -w net.ipv4.conf.all.rp_filter

sudo sysctl --system

# Installing wireguard
echo "deb http://deb.debian.org/debian buster-backports main" >> /etc/apt/sources.list
apt-get install -y wireguard openresolv

# Generate private and public key
wg genkey | tee /etc/wireguard/privatekey | wg pubkey > /etc/wireguard/publickey

echo "## Set Up WireGuard VPN on Debian By Editing/Creating wg0.conf File ##
[Interface]
## My VPN server private IP address ##
Address = 10.0.0.1/16

## My VPN server port ##
ListenPort = 51194

## VPN server's private key i.e. /etc/wireguard/privatekey ##
PrivateKey = qNwn/g+DPWgvKv4b54K3TmokV1YjrSWsIA0yXrseW1w=

## Save and update this config file when a new peer (vpn client) added ##
SaveConfig = true

PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE; ip6tables -A FORWARD -i wg0 -j ACCEPT; ip6tables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE; ip6tables -D FORWARD -i wg0 -j ACCEPT; ip6tables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
" > /etc/wireguard/wg0.conf


# Installing docker
apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates
echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu hirsute stable" > /etc/apt/sources.list.d/docker.list
curl -fsSL "https://download.docker.com/linux/ubuntu/gpg" | apt-key add -qq -
apt update
apt install -y containerd.io docker-ce docker-ce-cli
mkdir -p /etc/systemd/system/docker.service.d
cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF
systemctl daemon-reload 
systemctl restart docker
systemctl enable docker

# Add k8s repo and signing key
curl -fsSLo /etc/apt/trusted.gpg.d/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/etc/apt/trusted.gpg.d/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list
apt-get update

# Stopping swapp because k8s didn't support it
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
swapoff -a

# Isntalling k8s

apt-get install -y kubectl kubeadm kubelet

# Fix the current version (No auto-update)
apt-mark hold kubectl kubeadm kubelet

# Make k8s start at boot
systemctl enable --now kubelet

# Init the cluster first master
kubeadm init --apiserver-advertise-address 10.0.0.2 --control-plane-endpoint=10.0.0.1:6443 --pod-network-cidr=192.168.0.0/24 --upload-certs
# kubeadm join 10.0.0.1:6443 --token ****         --discovery-token-ca-cert-hash ****         --control-plane --certificate-key **** --apiserver-advertise-address 10.0.0.3
