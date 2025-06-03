#!/bin/bash

clear
echo "⚙️ Drosera Trap Auto Setup - Saint Khen (@admirkhen)"

# Check if root (optional safety)
if [ "$EUID" -eq 0 ]; then
  echo "⚠️ You're running as root. Foundry & Drosera install better as a non-root user."
  echo "You can continue, but PATH issues may occur. Proceeding anyway..."
fi

# Ask user input
read -p "🔐 Enter your EVM private key (no 0x): " evm_key
read -p "🌐 Enter your Ethereum Holesky RPC URL: " rpc_url
read -p "💬 Enter your Discord username (e.g. admirkhen#1234): " discord_username
read -p "🏦 Enter your wallet address: " wallet_address

# Install packages
echo "📦 Installing dependencies..."
apt update && apt install curl wget git unzip jq nano build-essential lz4 -y

# Install Foundry
echo "📥 Installing Foundry..."
curl -L https://foundry.paradigm.xyz | bash
export PATH="$HOME/.foundry/bin:$PATH"
source ~/.bashrc 2>/dev/null

echo "🔄 Installing Foundry toolchain..."
if command -v foundryup >/dev/null 2>&1; then
  foundryup
else
  echo "❌ foundryup not found in PATH. Trying manual path export..."
  export PATH="$HOME/.foundry/bin:$PATH"
  source ~/.bashrc
  command -v foundryup >/dev/null 2>&1 || { echo "❌ still can't find foundryup. Try restarting shell."; exit 1; }
  foundryup
fi

# Install Drosera CLI
echo "📥 Installing Drosera CLI..."
curl -L https://app.drosera.io/install | bash
export PATH="$HOME/.drosera/bin:$PATH"
source ~/.bashrc 2>/dev/null

echo "🔄 Installing Drosera CLI toolchain..."
if command -v droseraup >/dev/null 2>&1; then
  droseraup
else
  echo "❌ droseraup not found in PATH. Trying manual path export..."
  export PATH="$HOME/.drosera/bin:$PATH"
  source ~/.bashrc
  command -v droseraup >/dev/null 2>&1 || { echo "❌ still can't find droseraup. Try restarting shell."; exit 1; }
  droseraup
fi

# Set up directory
echo "📁 Setting up Trap directory..."
[ -d "my-drosera-trap" ] && rm -rf my-drosera-trap
forge init my-drosera-trap -t drosera-network/trap-foundry-template || { echo "❌ forge init failed."; exit 1; }
cd my-drosera-trap || exit 1

# Create Trap.sol
echo "📄 Creating Trap.sol..."
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

# Write drosera.toml
echo "🛠️ Writing drosera.toml..."
cat > drosera.toml <<EOF
path = "out/Trap.sol/Trap.json"
response_contract = "0x4608Afa7f277C8E0BE232232265850d1cDeB600E"
response_function = "respondWithDiscordName(string)"
EOF

# Build
echo "🔨 Building contract..."
forge build || { echo "❌ Build failed."; exit 1; }

# Dryrun
echo "🧪 Testing with drosera dryrun..."
drosera dryrun || echo "⚠️ dryrun failed (non-blocking)."

# Deploy
echo "🚀 Deploying Trap..."
DROSERA_PRIVATE_KEY=$evm_key drosera apply --eth-rpc-url $rpc_url || { echo "❌ Deployment failed."; exit 1; }

# Verify
echo "🧾 Verifying with isResponder()..."
cast call 0x4608Afa7f277C8E0BE232232265850d1cDeB600E "isResponder(address)(bool)" $wallet_address --rpc-url $rpc_url || echo "⚠️ Verification failed."

echo "✅ All done! Your Discord name trap is now deployed to Holesky."
