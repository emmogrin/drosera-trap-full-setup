#!/bin/bash

echo -e "\n=== ⚙️ Drosera Operator Setup (SystemD) ==="

# Trim helper
trim() { echo "$1" | xargs; }

# Input
read -p "Enter your Operator Private Key (same as Trap): " PRIVATE_KEY
PRIVATE_KEY=$(trim "$PRIVATE_KEY")

read -p "Enter your Ethereum Holesky RPC URL: " RPC_URL
RPC_URL=$(trim "$RPC_URL")

read -p "Enter your VPS Public IP: " VPS_IP
VPS_IP=$(trim "$VPS_IP")

# Install drosera-operator binary
cd ~
curl -LO https://github.com/drosera-network/releases/releases/download/v1.17.2/drosera-operator-v1.17.2-x86_64-unknown-linux-gnu.tar.gz
tar -xvf drosera-operator-v1.17.2-x86_64-unknown-linux-gnu.tar.gz
sudo cp drosera-operator /usr/bin

# Register
drosera-operator register --eth-rpc-url "$RPC_URL" --eth-private-key "$PRIVATE_KEY"

# Create SystemD service
sudo tee /etc/systemd/system/drosera.service > /dev/null <<EOF
[Unit]
Description=Drosera Operator Node
After=network-online.target

[Service]
User=$USER
Restart=always
RestartSec=10
LimitNOFILE=65535
ExecStart=/usr/bin/drosera-operator node --db-file-path $HOME/.drosera.db --network-p2p-port 31313 --server-port 31314 \
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

# Start
sudo systemctl daemon-reload
sudo systemctl enable drosera
sudo systemctl start drosera

echo -e "\n✅ Operator node is running!"
echo "🧠 Logs: journalctl -u drosera.service -f"
