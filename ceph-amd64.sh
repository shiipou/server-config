#!/bin/bash

# Downloading the cephadm binary and make it executable
wget -q -O- 'https://download.ceph.com/keys/release.asc' | sudo apt-key add -
echo deb https://download.ceph.com/debian-pacific buster main | sudo tee /etc/apt/sources.list.d/ceph.list
apt update && apt install ceph-deploy ntp

