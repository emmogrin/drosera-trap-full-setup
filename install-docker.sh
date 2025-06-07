#!/bin/bash
set -e

echo "🔧 Updating system packages..."
apt-get update && apt-get upgrade -y

echo "📦 Installing basic tools and dependencies..."
apt install -y curl ufw iptables build-essential git wget lz4 jq make gcc nano automake autoconf tmux htop nvme-cli \
libgbm1 pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip ca-certificates gnupg

# Detect OS type (Ubuntu or Debian)
. /etc/os-release
OS=$ID
CODENAME=$VERSION_CODENAME

if [[ "$OS" != "ubuntu" && "$OS" != "debian" ]]; then
  echo "❌ Unsupported OS: $OS"
  exit 1
fi

echo "🔐 Adding Docker GPG key..."
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/$OS/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

echo "📁 Adding Docker repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$OS \
  $CODENAME stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "📥 Updating package index..."
apt-get update

echo "🐳 Installing Docker..."
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "✅ Verifying Docker installation..."
docker --version && docker run hello-world

echo "🎉 Docker is installed and working!"
