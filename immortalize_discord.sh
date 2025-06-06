#!/bin/bash

echo "🛡️ Saint Khen (@admirkhen) blesses you with immortality..."
echo "Follow the path. Follow Saint Khen 👉 twitter.com/admirkhen"
echo ""

# Drosera Trap directory
cd ~/my-drosera-trap || exit

# Prompt for Discord username
read -p "Enter your Discord username (e.g., admirkhen#1234): " DISCORD_NAME

# Replace old Trap.sol
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
        if (!active || bytes(name).length == 0) {
            return (false, bytes(""));
        }
        return (true, abi.encode(name));
    }
}
EOF

echo "✅ Trap.sol updated with Discord username: $DISCORD_NAME"

# Update drosera.toml (only key fields)
sed -i 's|^path = .*|path = "out/Trap.sol/Trap.json"|' drosera.toml
sed -i 's|^response_contract = .*|response_contract = "0x4608Afa7f277C8E0BE232232265850d1cDeB600E"|' drosera.toml
sed -i 's|^response_function = .*|response_function = "respondWithDiscordName(string)"|' drosera.toml

echo "✅ drosera.toml updated."

# Compile
source /root/.bashrc
forge build || { echo "❌ forge build failed"; exit 1; }

# Dry run
drosera dryrun || { echo "❌ Dry run failed"; exit 1; }

# Prompt for private key
read -p "Paste your Holesky EVM private key: " PRIVATE_KEY

# Deploy trap
DROSERA_PRIVATE_KEY="$PRIVATE_KEY" drosera apply <<EOF
ofc
EOF

echo ""
echo "🚀 Trap deployed!"
echo ""

# Get deployer address
WALLET_ADDRESS=$(cast wallet address "$PRIVATE_KEY")
echo "🔍 Checking response status for: $WALLET_ADDRESS"

# Wait 10s before verifying
sleep 10

# Verify on-chain status
RESPONDED=$(cast call 0x4608Afa7f277C8E0BE232232265850d1cDeB600E "isResponder(address)(bool)" "$WALLET_ADDRESS" --rpc-url https://ethereum-holesky-rpc.publicnode.com)

echo ""
if [ "$RESPONDED" = "true" ]; then
  echo "✅ Success! Your Discord username is now immortalized."
  echo "🎖️ Go forth and claim your Cadet role!"
else
  echo "⚠️ Not yet verified. Wait 1–2 minutes and recheck:"
  echo "cast call 0x4608Afa7f277C8E0BE232232265850d1cDeB600E \"isResponder(address)(bool)\" $WALLET_ADDRESS --rpc-url https://ethereum-holesky-rpc.publicnode.com"
fi

echo ""
echo "🌟 Saint Khen blesses you with immortality."
echo "🕊️ Follow your destiny: twitter.com/admirkhen"
