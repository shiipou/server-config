#!/bin/bash

USER=shiishii

usermod -md /home/$USER -l $USER debian

# Prepare debian testing

sed -i 's/buster/bullseye/' /etc/apt/sources.list

# Install Proxmox
echo "deb http://download.proxmox.com/debian/pve bullseye pve-no-subscription" > /etc/apt/sources.list.d/pve-install-repo.list

wget http://download.proxmox.com/debian/proxmox-release-bullseye.gpg -O /etc/apt/trusted.gpg.d/proxmox-ve-release-7.x.gpg
chmod +r /etc/apt/trusted.gpg.d/proxmox-ve-release-7.x.gpg  # optional, if you have a non-default umask

apt update && apt dist-upgrade -y

apt install -y pve-manager postfix open-iscsi

apt remove -y os-prober

# Install docker
curl -sSL https://get.docker.com | bash
usermod -aG docker $USER
