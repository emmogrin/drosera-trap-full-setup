#!/bin/bash

# ──────────────── USER CONFIG ────────────────
GITHUB_EMAIL="youremail@gmail.com"
GITHUB_USERNAME="admirkhen"
DISCORD_USERNAME="admirkhen"                         # 🔥 Discord name to immortalize
PRIVATE_KEY="your_private_key_here"                 # 🔐 Must be funded Holesky EVM key
OWNER_ADDRESS="0xYourPublicWallet"                  # 📮 Wallet that owns the trap
RPC_URL="https://ethereum-holesky-rpc.publicnode.com"
# ─────────────────────────────────────────────

echo "🔧 Installing dependencies (No Docker needed)..."
sudo apt-get update && sudo apt-get upgrade -y
sudo apt install curl git wget build-essential unzip nano jq libssl-dev pkg-config libclang-dev libleveldb-dev tmux -y

echo "📦 Installing Foundry..."
curl -L https://foundry.paradigm.xyz | bash
source /root/.bashrc
foundryup

echo "📦 Installing Bun..."
curl -fsSL https://bun.sh/install | bash
source /root/.bashrc

echo "📦 Installing Drosera..."
curl -L https://app.drosera.io/install | bash
source /root/.bashrc
droseraup

echo "📁 Setting up trap project folder..."
mkdir -p my-drosera-trap && cd my-drosera-trap
git config --global user.email "$GITHUB_EMAIL"
git config --global user.name "$GITHUB_USERNAME"
forge init -t drosera-network/trap-foundry-template

echo "📦 Installing Bun deps..."
bun install

echo "🔧 Writing Trap.sol (Discord Cadet)..."
cat > src/Trap.sol <<EOF
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ITrap} from "drosera-contracts/interfaces/ITrap.sol";

interface IMockResponse {
    function isActive() external view returns (bool);
}

contract Trap is ITrap {
    address public constant RESPONSE_CONTRACT = 0x4608Afa7f277C8E0BE232232265850d1cDeB600E;
    string constant discordName = "$DISCORD_USERNAME";

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

echo "📝 Updating drosera.toml..."
cat > drosera.toml <<EOF
path = "out/Trap.sol/Trap.json"
response_contract = "0x4608Afa7f277C8E0BE232232265850d1cDeB600E"
response_function = "respondWithDiscordName(string)"
EOF

echo "🔨 Building contract..."
forge build

echo "🧪 Dry run check..."
drosera dryrun

echo "🚀 Deploying trap with Discord Cadet name..."
DROSERA_PRIVATE_KEY=$PRIVATE_KEY drosera apply --eth-rpc-url $RPC_URL <<< "ofc"

echo "🧬 Verifying if your address is now a responder..."
cast call 0x4608Afa7f277C8E0BE232232265850d1cDeB600E \
  "isResponder(address)(bool)" $OWNER_ADDRESS \
  --rpc-url $RPC_URL

echo "📜 Fetching all on-chain Discord usernames..."
cast call 0x4608Afa7f277C8E0BE232232265850d1cDeB600E \
  "getDiscordNamesBatch(uint256,uint256)(string[])" 0 2000 \
  --rpc-url $RPC_URL

echo -e "\n✅ ALL DONE. Your trap is deployed and your Discord '$DISCORD_USERNAME' is now immortalized on-chain. 🔥"
echo -e "\n💎 Saint Khen @admirkhen blesses this deployment."
