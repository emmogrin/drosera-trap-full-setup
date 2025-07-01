#!/bin/bash
set -e

echo "==============================================="
echo "🔺 UCHIHA SAINT WELCOMES YOU TO THE DROSERA HOODI TESTNET 🔺"
echo "==============================================="
echo
echo "🌒 The Infinite Tsukuyomi of Traps Awaits..."
echo

echo "=== Step 1: Install Drosera CLI ==="
curl -L https://app.drosera.io/install | bash
source ~/.bashrc
droseraup

echo "=== Step 2: Install Foundry CLI ==="
curl -L https://foundry.paradigm.xyz | bash
source ~/.bashrc
foundryup

echo "=== Step 3: Install Bun ==="
curl -fsSL https://bun.sh/install | bash
source ~/.bashrc

echo "=== Step 4: Prepare Trap Directory ==="
mkdir -p ~/my-drosera-trap
cd ~/my-drosera-trap

read -p "Enter your Github Email: " GITHUB_EMAIL
read -p "Enter your Github Username: " GITHUB_USER

git config --global user.email "$GITHUB_EMAIL"
git config --global user.name "$GITHUB_USER"

echo "=== Step 5: Initialize Trap Project ==="
forge init -t drosera-network/trap-foundry-template

echo "=== Step 6: Compile Trap ==="
bun install
forge build

echo "=== Step 7: Deploy Trap ==="
read -p "Enter your DROSERA_PRIVATE_KEY (hex, no 0x prefix): " DROSERA_PRIVATE_KEY
read -p "Enter your Ethereum RPC URL (e.g. Hoodi): " ETH_RPC_URL

echo "=== Step 8: Privacy Settings ==="
read -p "Do you want your trap to be private? (y/N): " PRIVATE_TRAP
if [[ "$PRIVATE_TRAP" =~ ^[Yy]$ ]]; then
  echo "🔒 Setting trap as private..."

  # Add only if not already present
  grep -q "private_trap" drosera.toml || sed -i '/\[traps.mytrap\]/a private_trap = true' drosera.toml

  read -p "Enter your whitelist operator addresses separated by commas (Operator1_Address,Operator2_Address,...): " WHITELIST
  IFS=',' read -ra ADDRS <<< "$WHITELIST"

  # Remove old whitelist first if exists
  sed -i '/whitelist = \[/,/]/d' drosera.toml

  echo "Creating whitelist..."
  echo "whitelist = [" > whitelist.tmp
  for addr in "${ADDRS[@]}"; do
    echo "  \"$addr\"," >> whitelist.tmp
  done
  echo "]" >> whitelist.tmp

  sed -i "/\[traps.mytrap\]/r whitelist.tmp" drosera.toml
  rm whitelist.tmp
fi

echo "=== Deploying Trap... ==="
DROSERA_PRIVATE_KEY="$DROSERA_PRIVATE_KEY" drosera apply --eth-rpc-url "$ETH_RPC_URL"

echo "=== Step 9: Bloom Boost Trap ==="
echo "Visit https://app.drosera.io/"
echo "Click 'Send Bloom Boost' to deposit Hoodi ETH."

echo "=== Step 10: Done. Uchiha Saint Approves. 🔺"
