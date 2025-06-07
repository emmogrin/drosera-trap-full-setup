#!/bin/bash
set -e

echo "Updating system packages..."
apt-get update && apt-get upgrade -y

echo "Installing basic utilities and dependencies..."
apt install -y curl ufw iptables build-essential git wget lz4 jq make gcc nano automake autoconf tmux htop nvme-cli libgbm1 pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip libleveldb-dev

echo "Installing Docker via official Docker install script..."
curl -fsSL https://get.docker.com | sh

echo "Testing Docker installation..."
docker run hello-world

echo "Docker installation completed successfully!"
