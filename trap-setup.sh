#!/bin/bash

echo -e "\n=== 🎯 Drosera Trap Setup ==="

# Trim helper
trim() { echo "$1" | xargs; }

# Input
read -p "Enter your Trap EVM Private Key (64 hex): " PRIVATE_KEY
PRIVATE_KEY=$(trim "$PRIVATE_KEY")

read -p "Enter your Ethereum Holesky RPC URL: " RPC_URL
RPC_URL=$(trim "$RPC_URL")

read -p "Enter your GitHub Email: " GITHUB_EMAIL
read -p "Enter your GitHub Username: " GITHUB_USER

read -p "Enter your Operator Address (0x...): " OPERATOR_ADDR
read -p "Enter your Discord Username (for immortalization, e.g. admirkhen#1234): " DISCORD_NAME
DISCORD_NAME=$(trim "$DISCORD_NAME")

# Update system + tools
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl git unzip jq build-essential pkg-config libssl-dev liblz4-tool

# Install drosera, foundry, bun
curl -L https://app.drosera.io/install | bash && source ~/.bashrc && droseraup
curl -L https://foundry.paradigm.xyz | bash && source ~/.bashrc && foundryup
curl -fsSL https://bun.sh/install | bash && source ~/.bashrc

# Init trap
mkdir -p ~/my-drosera-trap && cd ~/my-drosera-trap
git config --global user.email "$GITHUB_EMAIL"
git config --global user.name "$GITHUB_USER"
forge init -t drosera-network/trap-foundry-template

# Write Trap.sol
cat <<EOF > src/Trap.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ITrap} from "drosera-contracts/interfaces/ITrap.sol";
interface IMockResponse {
    function isActive() external view returns (bool);
}
contract Trap is ITrap {
    address public constant RESPONSE_CONTRACT = 0x4608Afa7f277C8E0BE232232265850d1cDeB600E;
    string constant discordName = "$DISCORD_NAME";
    function collect() external view returns (bytes memory) {
        bool active = IMockResponse(RESPONSE_CONTRACT).isActive();
        return abi.encode(active, discordName);
    }
    function shouldRespond(bytes[] calldata data) external pure returns (bool, bytes memory) {
        (bool active, string memory name) = abi.decode(data[0], (bool, string));
        if (!active || bytes(name).length == 0) return (false, bytes(""));
        return (true, abi.encode(name));
    }
}
EOF

# Fix config
sed -i 's|path = .*|path = "out/Trap.sol/Trap.json"|' drosera.toml
echo "private_trap = true" >> drosera.toml
echo "whitelist = [\"$OPERATOR_ADDR\"]" >> drosera.toml
echo 'response_contract = "0x4608Afa7f277C8E0BE232232265850d1cDeB600E"' >> drosera.toml
echo 'response_function = "respondWithDiscordName(string)"' >> drosera.toml

# Build + Deploy
bun install
forge build

DROSERA_PRIVATE_KEY="$PRIVATE_KEY" drosera apply --eth-rpc-url "$RPC_URL" --discord "$DISCORD_NAME" --github "$GITHUB_USER"

echo -e "\n✅ Trap deployed and immortalization request sent!"
