#!/bin/bash
set -e

BASHRC_PATH="$HOME/.bashrc"

echo "=== Step 1: Install Drosera CLI ==="
curl -L https://app.drosera.io/install | bash
if [ -f "$BASHRC_PATH" ]; then
  source "$BASHRC_PATH"
fi
droseraup

echo "=== Step 2: Install Foundry CLI ==="
curl -L https://foundry.paradigm.xyz | bash
if [ -f "$BASHRC_PATH" ]; then
  source "$BASHRC_PATH"
fi
foundryup

echo "=== Step 3: Install Bun ==="
curl -fsSL https://bun.sh/install | bash
if [ -f "$BASHRC_PATH" ]; then
  source "$BASHRC_PATH"
fi

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
read -p "Enter your Ethereum RPC URL (e.g. Holesky): " ETH_RPC_URL

DROSERA_PRIVATE_KEY="$DROSERA_PRIVATE_KEY" drosera apply --eth-rpc-url "$ETH_RPC_URL"

echo "=== Step 8: Existing User Trap Address Setup (optional) ==="
read -p "Are you an existing user needing to add trap address? (y/N): " EXISTING_USER
if [[ "$EXISTING_USER" =~ ^[Yy]$ ]]; then
  read -p "Enter your TRAP_ADDRESS (0x...): " TRAP_ADDRESS
  read -p "Enter your whitelist operator addresses separated by commas: " WHITELIST
  echo "" >> drosera.toml
  echo "address = \"$TRAP_ADDRESS\"" >> drosera.toml
  IFS=',' read -ra ADDRS <<< "$WHITELIST"
  printf 'whitelist = [\n' >> drosera.toml
  for addr in "${ADDRS[@]}"; do
    printf '  "%s",\n' "$addr" >> drosera.toml
  done
  printf ']\n' >> drosera.toml

  DROSERA_PRIVATE_KEY="$DROSERA_PRIVATE_KEY" drosera apply --eth-rpc-url "$ETH_RPC_URL"
fi

echo "=== Step 9: Check Trap on Dashboard ==="
echo "Visit https://app.drosera.io/ and connect your wallet."

echo "=== Step 10: Bloom Boost Trap ==="
echo "Open your Trap on Dashboard and click 'Send Bloom Boost' to deposit some Holesky ETH."

echo "=== Step 11: Fetch Blocks (dryrun) ==="
drosera dryrun

echo "=== ✅ Setup Complete ==="
