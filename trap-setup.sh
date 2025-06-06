#!/bin/bash

echo -e "\n=== 🎯 Drosera Trap Setup ==="

# Trim helper
trim() { echo "$1" | xargs; }

# Input
read -p "Enter your Trap EVM Private Key (64 hex, no 0x prefix): " PRIVATE_KEY
PRIVATE_KEY=$(trim "$PRIVATE_KEY")

read -p "Enter your Ethereum Holesky RPC URL: " RPC_URL
RPC_URL=$(trim "$RPC_URL")

read -p "Enter your GitHub Email: " GITHUB_EMAIL
read -p "Enter your GitHub Username: " GITHUB_USER

read -p "Enter your Operator Address (0x...): " OPERATOR_ADDR
OPERATOR_ADDR=$(trim "$OPERATOR_ADDR")

read -p "Enter your Discord Username (e.g. admirkhen#1234): " DISCORD_NAME
DISCORD_NAME=$(trim "$DISCORD_NAME")

# Update system + install essentials
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl git unzip jq build-essential pkg-config libssl-dev liblz4-tool

# Install drosera, foundry, bun
curl -L https://app.drosera.io/install | bash && source ~/.bashrc && droseraup
curl -L https://foundry.paradigm.xyz | bash && source ~/.bashrc && foundryup
curl -fsSL https://bun.sh/install | bash && source ~/.bashrc

# Init drosera trap project
mkdir -p ~/my-drosera-trap && cd ~/my-drosera-trap
git config --global user.email "$GITHUB_EMAIL"
git config --global user.name "$GITHUB_USER"
forge init -t drosera-network/trap-foundry-template

# Optional: Replace or modify the default Trap.sol if needed
# This keeps the default HelloWorldTrap.sol

# Update drosera.toml
sed -i 's|path = .*|path = "out/HelloWorldTrap.sol/HelloWorldTrap.json"|' drosera.toml
echo "private_trap = true" >> drosera.toml
echo "whitelist = [\"$OPERATOR_ADDR\"]" >> drosera.toml
echo 'response_contract = "0x4608Afa7f277C8E0BE232232265850d1cDeB600E"' >> drosera.toml
echo 'response_function = "respondWithDiscordName(string)"' >> drosera.toml

# Build and deploy
bun install
forge build

DROSERA_PRIVATE_KEY="$PRIVATE_KEY" drosera apply --eth-rpc-url "$RPC_URL" --discord "$DISCORD_NAME"

echo -e "\n✅ Trap deployed and immortalization sent!"
