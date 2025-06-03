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
sudo apt update && sudo apt install curl wget git unzip jq nano build-essential lz4 -y

echo "📥 Installing Foundry..."
curl -L https://foundry.paradigm.xyz | bash

echo "🔄 Reloading environment..."
source ~/.bashrc

echo "⚙️ Running foundryup to install Foundry toolchain..."
foundryup || { echo "❌ foundryup failed. Please run 'source ~/.bashrc' manually and rerun this script."; exit 1; }

echo "📥 Installing Drosera CLI..."
curl -L https://app.drosera.io/install | bash

echo "🔄 Reloading environment..."
source ~/.bashrc

echo "⚙️ Running droseraup to install Drosera CLI..."
droseraup || { echo "❌ droseraup failed. Please run 'source ~/.bashrc' manually and rerun this script."; exit 1; }

if [ -d "my-drosera-trap" ]; then
  echo "📁 Directory 'my-drosera-trap' already exists. Removing it for a clean setup..."
  rm -rf my-drosera-trap
fi

echo "📁 Creating Trap directory..."
forge init my-drosera-trap -t drosera-network/trap-foundry-template
cd my-drosera-trap || { echo "❌ Failed to enter my-drosera-trap directory."; exit 1; }

echo "📄 Creating Trap.sol with your Discord username..."
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
path = "out/Trap.sol/Trap.json"
response_contract = "0x4608Afa7f277C8E0BE232232265850d1cDeB600E"
response_function = "respondWithDiscordName(string)"
EOF

echo "🔨 Building contract..."
forge build || { echo "❌ Build failed. Fix errors above before continuing."; exit 1; }

echo "🧪 Testing Trap with dryrun..."
drosera dryrun || echo "⚠️ Dryrun failed or returned errors."

echo "🚀 Deploying Trap to Holesky..."
DROSERA_PRIVATE_KEY=$evm_key drosera apply --eth-rpc-url $rpc_url || { echo "❌ Deployment failed."; exit 1; }

echo "🧾 Verifying isResponder() for your wallet..."
cast call 0x4608Afa7f277C8E0BE232232265850d1cDeB600E "isResponder(address)(bool)" $wallet_address --rpc-url $rpc_url || echo "⚠️ Verification call failed."

echo "✅ Done! Your Discord name should now be immortalized on-chain."
