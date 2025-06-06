#!/bin/bash

echo "───────────────────────────────────────────────"
echo "   🪤 DROSERA IMMORTALIZATION SETUP - by @admirkhen"
echo "───────────────────────────────────────────────"

# Prompt for Discord username
read -p "Enter your Discord username (e.g., admirkhen#0001): " DISCORD_NAME

# Prompt for EVM private key (won't echo)
read -s -p "Enter your EVM private key (starts with 0x): " PRIVATE_KEY
echo ""

# Set trap name
TRAP_NAME="mytrap"

# Clone template if not already
if [ ! -d "my-drosera-trap" ]; then
  git clone https://github.com/drosera-network/trap-foundry-template.git my-drosera-trap
fi

cd my-drosera-trap

# Create the Trap.sol file
cat <<EOF > src/Trap.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ITrap} from "drosera-contracts/interfaces/ITrap.sol";

interface IMockResponse {
    function isActive() external view returns (bool);
}

contract Trap is ITrap {
    address public constant RESPONSE_CONTRACT = 0x4608Afa7f277C8E0BE232232265850d1cDeB600E;
    string constant discordName = "${DISCORD_NAME}";

    function collect() external view returns (bytes memory) {
        bool active = IMockResponse(RESPONSE_CONTRACT).isActive();
        return abi.encode(active, discordName);
    }

    function shouldRespond(bytes[] calldata data) external pure returns (bool, bytes memory) {
        (bool active, string memory name) = abi.decode(data[0], (bool, string));
        if (!active || bytes(name).length == 0) {
            return (false, bytes(""));
        }
        return (true, abi.encode(name));
    }
}
EOF

echo "✅ Trap.sol created with your Discord name"

# Create drosera.toml
cat <<EOF > drosera.toml
ethereum_rpc = "https://ethereum-holesky-rpc.publicnode.com"
drosera_rpc = "https://relay.testnet.drosera.io"
eth_chain_id = 17000
drosera_address = "0xea08f7d533C2b9A62F40D5326214f39a8E3A32F8"

[traps]
[traps.${TRAP_NAME}]
path = "out/Trap.sol/Trap.json"
response_contract = "0x4608Afa7f277C8E0BE232232265850d1cDeB600E"
response_function = "respondWithDiscordName(string)"
cooldown_period_blocks = 33
min_number_of_operators = 1
max_number_of_operators = 2
block_sample_size = 1
private_trap = true
whitelist = true
EOF

echo "✅ drosera.toml configured"

# Compile the trap
echo "⏳ Compiling contract..."
forge build

# Dryrun
echo "⏳ Testing trap with dryrun..."
drosera dryrun

# Deploy
echo "🚀 Deploying trap to Holesky..."
DROSERA_PRIVATE_KEY=$PRIVATE_KEY drosera apply

echo ""
echo "✅ Trap deployed and immortalization sent!"

# Instructions for verifying response
echo ""
echo "🔍 To verify your Trap is active, run:"
echo "source ~/.bashrc"
echo "cast call 0x4608Afa7f277C8E0BE232232265850d1cDeB600E \"isResponder(address)(bool)\" YOUR_WALLET --rpc-url https://ethereum-holesky-rpc.publicnode.com"
echo ""
echo "🔁 To restart your operator node if needed:"
echo "cd ~/Drosera-Network && docker compose up -d"

echo ""
echo "🎉 Done! Welcome, Immortal Cadet 🧙‍♂️"
