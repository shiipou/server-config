#!/bin/bash

USER=shiishii

DEBIAN_FRONTEND=noninteractive

usermod -md /home/$USER -l $USER pi

# Install Proxmox
curl https://gitlab.com/minkebox/pimox/-/raw/master/dev/KEY.gpg | apt-key add -
curl https://gitlab.com/minkebox/pimox/-/raw/master/dev/pimox.list > /etc/apt/sources.list.d/pimox.list

apt update && apt dist-upgrade -y

apt install -y pve-manager

# Install docker
curl -sSL https://get.docker.com | bash
usermod -aG docker $USER
