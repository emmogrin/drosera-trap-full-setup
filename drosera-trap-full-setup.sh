#!/bin/bash

# Drosera Trap Full Setup (Proot-distro Compatible)
# Saint Khen @admirkhen

# Update system
apt-get update && apt-get upgrade -y

# Install required packages
apt install curl git wget build-essential make gcc nano automake autoconf \
tmux htop libgbm1 pkg-config libssl-dev libleveldb-dev tar clang \
bsdmainutils ncdu unzip jq -y

# Install Drosera CLI
curl -L https://app.drosera.io/install | bash
source ~/.bashrc || source ~/.profile
droseraup

# Install Foundry
curl -L https://foundry.paradigm.xyz | bash
source ~/.bashrc || source ~/.profile
foundryup

# Install Bun
curl -fsSL https://bun.sh/install | bash
source ~/.bashrc || source ~/.profile

# Clone trap repo
mkdir my-drosera-trap && cd my-drosera-trap
git config --global user.email "Github_Email"
git config --global user.name "Github_Username"
forge init -t drosera-network/trap-foundry-template

# Install dependencies & build trap
bun install
forge build

# Deploy trap
# Replace PRIVATE_KEY with your private key
DROSERA_PRIVATE_KEY=PRIVATE_KEY drosera apply --eth-rpc-url https://ethereum-holesky-rpc.publicnode.com

# Check trap dryrun
drosera dryrun

# Add custom trap to submit Discord name
cat <<EOF > src/Trap.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ITrap} from "drosera-contracts/interfaces/ITrap.sol";

interface IMockResponse {
    function isActive() external view returns (bool);
}

contract Trap is ITrap {
    address public constant RESPONSE_CONTRACT = 0x4608Afa7f277C8E0BE232232265850d1cDeB600E;
    string constant discordName = "DISCORD_USERNAME";

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

# Update drosera.toml config
cat <<EOF > drosera.toml
path = "out/Trap.sol/Trap.json"
response_contract = "0x4608Afa7f277C8E0BE232232265850d1cDeB600E"
response_function = "respondWithDiscordName(string)"
EOF

# Rebuild and deploy new trap
forge build
drosera dryrun
DROSERA_PRIVATE_KEY=PRIVATE_KEY drosera apply

# Verify if trap is responding
source ~/.bashrc || source ~/.profile
cast call 0x4608Afa7f277C8E0BE232232265850d1cDeB600E "isResponder(address)(bool)" YOUR_WALLET_ADDRESS --rpc-url https://ethereum-holesky-rpc.publicnode.com

# View all submitted Discord names
cast call 0x4608Afa7f277C8E0BE232232265850d1cDeB600E "getDiscordNamesBatch(uint256,uint256)(string[])" 0 2000 --rpc-url https://ethereum-holesky-rpc.publicnode.com

echo "✅ Completed by Saint Khen @admirkhen — Trap deployed & Discord name submitted on-chain."
