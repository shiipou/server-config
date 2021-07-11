#!/bin/bash

# Downloading the cephadm binary and make it executable
curl --silent --remote-name --location https://github.com/ceph/ceph/raw/pacific/src/cephadm/cephadm
chmod +x cephadm

# Add the apt debian repo for ceph cluster binaries
./cephadm add-repo --release pacific --repo-url "https://download.ceph.com/debian-pacific buster Release"

# Install it
./cephadm install

