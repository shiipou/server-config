#!/bin/bash

sudo -s

# Install Proxmox
echo "deb http://download.proxmox.com/debian/pve buster pve-no-subscription" > /etc/apt/sources.list.d/pve-install-repo.list

wget http://download.proxmox.com/debian/proxmox-ve-release-6.x.gpg -O /etc/apt/trusted.gpg.d/proxmox-ve-release-6.x.gpg
chmod +r /etc/apt/trusted.gpg.d/proxmox-ve-release-6.x.gpg  # optional, if you have a non-default umask

apt update && apt full-upgrade -y

apt install proxmox-ve postfix open-iscsi

apt remove os-prober

# Install docker
curl -sSL https://get.docker.com | bash
usermod -aG docker $USER
