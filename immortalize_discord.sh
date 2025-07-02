#!/bin/bash

echo "🛡️ Saint Khen (@admirkhen) blesses you with immortality..."
echo "Follow the path 👉 twitter.com/admirkhen"
echo ""

cd ~/my-drosera-trap || { echo "❌ Trap folder not found. Did you deploy your trap yet?"; exit 1; }

read -p "👤 Enter your Discord username (e.g., admirkhen#1234): " DISCORD_NAME

cat <<EOF > src/Trap.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ITrap} from "drosera-contracts/interfaces/ITrap.sol";

interface IMockResponse {
    function isActive() external view returns (bool);
}

contract Trap is ITrap {
    address public constant RESPONSE_CONTRACT = 0x25E2CeF36020A736CF8a4D2cAdD2EBE3940F4608;
    string constant discordName = "$DISCORD_NAME";

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

echo "✅ Trap.sol updated."

# Update drosera.toml to match this Trap
sed -i 's|^path = .*|path = "out/Trap.sol/Trap.json"|' drosera.toml
sed -i 's|^response_contract = .*|response_contract = "0x25E2CeF36020A736CF8a4D2cAdD2EBE3940F4608"|' drosera.toml
sed -i 's|^response_function = .*|response_function = "respondWithDiscordName(string)"|' drosera.toml

# Ensure Hoodi testnet settings
sed -i 's|^drosera_rpc = .*|drosera_rpc = "https://relay.hoodi.drosera.io"|' drosera.toml
sed -i 's|^eth_chain_id = .*|eth_chain_id = 560048|' drosera.toml
sed -i 's|^drosera_address = .*|drosera_address = "0x91cB447BaFc6e0EA0F4Fe056F5a9b1F14bb06e5D"|' drosera.toml

echo "✅ drosera.toml updated for Hoodi."

source ~/.bashrc

forge build || { echo "❌ forge build failed"; exit 1; }
drosera dryrun || { echo "❌ Drosera dry run failed"; exit 1; }

read -p "🔑 Paste your Hoodi EVM private key: " PRIVATE_KEY

DROSERA_PRIVATE_KEY="$PRIVATE_KEY" drosera apply <<< "ofc"
echo "🚀 Trap deployed!"

WALLET_ADDRESS=$(cast wallet address "$PRIVATE_KEY")
echo "🔍 Verifying on-chain status for: $WALLET_ADDRESS"

sleep 10

RESPONDED=$(cast call 0x25E2CeF36020A736CF8a4D2cAdD2EBE3940F4608 "isResponder(address)(bool)" "$WALLET_ADDRESS" --rpc-url https://eth-hoodi.g.alchemy.com/v2/SDctBqvoTyj4LBriVGJPE)

if [ "$RESPONDED" = "true" ]; then
  echo "✅ Success! Your Discord name is now immortalized on Hoodi."
  echo "🎖️ Claim your Cadet role on Discord!"
else
  echo "⚠️ Not yet verified. Try again in 1–2 minutes:"
  echo "cast call 0x25E2CeF36020A736CF8a4D2cAdD2EBE3940F4608 \"isResponder(address)(bool)\" $WALLET_ADDRESS --rpc-url https://eth-hoodi.g.alchemy.com/v2/SDctBqvoTyj4LBriVGJPE"
fi

echo ""
echo "🕊️ Saint Khen watches over you. Stay immortal."
