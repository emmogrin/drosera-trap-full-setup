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

echo "✅ Trap.sol updated."

# Auto-update drosera.toml
sed -i 's|^path = .*|path = "out/Trap.sol/Trap.json"|' drosera.toml
sed -i 's|^response_contract = .*|response_contract = "0x4608Afa7f277C8E0BE232232265850d1cDeB600E"|' drosera.toml
sed -i 's|^response_function = .*|response_function = "respondWithDiscordName(string)"|' drosera.toml
echo "✅ drosera.toml updated."

source ~/.bashrc

forge build || { echo "❌ forge build failed"; exit 1; }
drosera dryrun || { echo "❌ Drosera dry run failed"; exit 1; }

read -p "🔑 Paste your Holesky EVM private key: " PRIVATE_KEY

# Deploy with Drosera CLI
DROSERA_PRIVATE_KEY="$PRIVATE_KEY" drosera apply <<< "ofc"
echo "🚀 Trap deployed!"

# Get wallet address
WALLET_ADDRESS=$(cast wallet address "$PRIVATE_KEY")
echo "🔍 Verifying on-chain status for: $WALLET_ADDRESS"

sleep 10

RESPONDED=$(cast call 0x4608Afa7f277C8E0BE232232265850d1cDeB600E "isResponder(address)(bool)" "$WALLET_ADDRESS" --rpc-url https://ethereum-holesky-rpc.publicnode.com)

if [ "$RESPONDED" = "true" ]; then
  echo "✅ Success! Your Discord name is now immortalized on-chain."
  echo "🎖️ Claim your Cadet role on Discord!"
else
  echo "⚠️ Not yet verified. Try again in 1–2 minutes:"
  echo "cast call 0x4608Afa7f277C8E0BE232232265850d1cDeB600E \"isResponder(address)(bool)\" $WALLET_ADDRESS --rpc-url https://ethereum-holesky-rpc.publicnode.com"
fi

echo ""
echo "🕊️ Saint Khen watches over you. Stay immortal."
echo ""

# 🔧 SYSTEMD DROPSERA SERVICE SETUP
read -p "📡 Enter your VPS public IP (no port, just IP): " VPS_IP
read -p "🌐 Enter your Holesky RPC URL (Alchemy, QuickNode, etc): " RPC_URL

sudo tee /etc/systemd/system/drosera.service > /dev/null <<EOF
[Unit]
Description=Drosera Operator Service
After=network-online.target

[Service]
User=$USER
Restart=always
RestartSec=15
LimitNOFILE=65535
ExecStart=$(which drosera-operator) node \
  --db-file-path $HOME/.drosera.db \
  --network-p2p-port 31313 \
  --server-port 31314 \
  --eth-rpc-url $RPC_URL \
  --eth-backup-rpc-url https://1rpc.io/holesky \
  --drosera-address 0xea08f7d533C2b9A62F40D5326214f39a8E3A32F8 \
  --eth-private-key $PRIVATE_KEY \
  --listen-address 0.0.0.0 \
  --network-external-p2p-address $VPS_IP \
  --disable-dnr-confirmation true

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable drosera
sudo systemctl restart drosera

echo ""
echo "🔧 drosera-operator service installed and started!"
echo "🖥️ To check logs: sudo journalctl -fu drosera"
