#!/bin/bash

echo -e "\n=== 🎯 Drosera Trap Setup ==="

trim() { echo "$1" | xargs; }

read -p "Enter your Trap EVM Private Key (64 hex): " PRIVATE_KEY
PRIVATE_KEY=$(trim "$PRIVATE_KEY")

read -p "Enter your Ethereum Holesky RPC URL: " RPC_URL
RPC_URL=$(trim "$RPC_URL")

# Update system + tools
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl git unzip jq build-essential pkg-config libssl-dev liblz4-tool

# Install drosera, foundry, bun
curl -L https://app.drosera.io/install | bash && source ~/.bashrc && droseraup
curl -L https://foundry.paradigm.xyz | bash && source ~/.bashrc && foundryup
curl -fsSL https://bun.sh/install | bash && source ~/.bashrc
export PATH="$HOME/.bun/bin:$PATH"

# Init trap (no need for git email/username if using forge init)
mkdir -p ~/my-drosera-trap && cd ~/my-drosera-trap
forge init -t drosera-network/trap-foundry-template

# Write Trap.sol without Discord
cat <<EOF > src/Trap.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ITrap} from "drosera-contracts/interfaces/ITrap.sol";
interface IMockResponse {
    function isActive() external view returns (bool);
}
contract Trap is ITrap {
    address public constant RESPONSE_CONTRACT = 0x4608Afa7f277C8E0BE232232265850d1cDeB600E;
    function collect() external view returns (bytes memory) {
        bool active = IMockResponse(RESPONSE_CONTRACT).isActive();
        return abi.encode(active);
    }
    function shouldRespond(bytes[] calldata data) external pure returns (bool, bytes memory) {
        (bool active) = abi.decode(data[0], (bool));
        if (!active) return (false, bytes(""));
        return (true, abi.encode(""));
    }
}
EOF

# Fix config
sed -i 's|path = .*|path = "out/Trap.sol/Trap.json"|' drosera.toml
echo "private_trap = true" >> drosera.toml

# Build + Deploy
bun install
forge build

DROSERA_PRIVATE_KEY="$PRIVATE_KEY" drosera apply --eth-rpc-url "$RPC_URL"

echo -e "\n✅ Trap deployed!"
