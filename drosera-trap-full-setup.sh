#!/bin/bash

clear
echo "⚙️ Drosera Trap Auto Setup - Saint Khen (@admirkhen)"
echo "🔐 Enter your EVM private key (no 0x):"
read -p "> " evm_key

echo "🌐 Enter your Ethereum Holesky RPC URL (e.g., from Alchemy or QuickNode):"
read -p "> " rpc_url

echo "💬 Enter your Discord username (e.g., admirkhen#1234):"
read -p "> " discord_username

echo "🏦 Enter your wallet address (for verification check):"
read -p "> " wallet_address

echo "📦 Installing dependencies..."
apt update && apt install curl wget git unzip jq nano build-essential lz4 -y

echo "📥 Installing Foundry..."
curl -L https://foundry.paradigm.xyz | bash
export PATH="$HOME/.foundry/bin:$PATH"
foundryup || echo "⚠️ foundryup failed — try 'source ~/.bashrc' manually."

echo "📥 Installing Drosera CLI..."
curl -L https://app.drosera.io/install | bash
export PATH="$HOME/.drosera/bin:$PATH"
droseraup || echo "⚠️ droseraup failed — try 'source ~/.bashrc' manually."

echo "📁 Setting up Trap directory..."
forge init my-drosera-trap -t drosera-network/trap-foundry-template
cd my-drosera-trap

echo 'drosera-contracts=lib/contracts' > remappings.txt
forge install drosera-network/contracts

echo "📄 Creating Trap.sol with your Discord username..."
mkdir -p src
cat > src/Trap.sol <<EOF
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ITrap} from "drosera-contracts/interfaces/ITrap.sol";

interface IMockResponse {
    function isActive() external view returns (bool);
}

contract Trap is ITrap {
    address public constant RESPONSE_CONTRACT = 0x4608Afa7f277C8E0BE232232265850d1cDeB600E;
    string constant discordName = "${discord_username}";

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

echo "🛠️ Writing drosera.toml config..."
cat > drosera.toml <<EOF
ethereum_rpc = "${rpc_url}"

[[traps]]
name = "Trap"
path = "out/Trap.sol/Trap.json"
response_contract = "0x4608Afa7f277C8E0BE232232265850d1cDeB600E"
response_function = "respondWithDiscordName(string)"
EOF

echo "🔨 Building contract..."
forge build || { echo "❌ Build failed. Fix errors above."; exit 1; }

echo "🧪 Testing Trap with dryrun..."
drosera dryrun

echo "🚀 Deploying Trap to Holesky..."
DROSERA_PRIVATE_KEY=$evm_key drosera apply --eth-rpc-url $rpc_url

echo "🧾 Verifying isResponder() for your wallet..."
cast call 0x4608Afa7f277C8E0BE232232265850d1cDeB600E "isResponder(address)(bool)" $wallet_address --rpc-url $rpc_url

echo "✅ Done! Your Discord name should now be immortalized on-chain."
