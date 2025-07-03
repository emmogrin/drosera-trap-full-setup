#!/usr/bin/env bash

echo "============================================"
echo "    🪲 Drosera Operator VPS/PC Setup Script"
echo "============================================"
echo ""

# ✅ 1. Prompt user for private key and VPS IP
read -p "👉 Enter your ETH private key (no 0x): " PV_KEY
read -p "👉 Enter your VPS public IP address: " VPS_IP
read -p "👉 Enter your Trap address to opt-in: " TRAP_ADDR

# ✅ 2. Make working dir
mkdir -p ~/Drosera-Network
cd ~/Drosera-Network

# ✅ 3. Stop & cleanup old service
sudo systemctl stop drosera 2>/dev/null
sudo systemctl disable drosera 2>/dev/null
sudo rm -f /etc/systemd/system/drosera.service
sudo systemctl daemon-reload

# ✅ 4. Setup UFW *before* running the node
sudo ufw allow ssh
sudo ufw allow 22
sudo ufw allow 31313/tcp
sudo ufw allow 31314/tcp
sudo ufw --force enable

# ✅ 5. Create new systemd service
sudo tee /etc/systemd/system/drosera.service > /dev/null <<EOF
[Unit]
Description=Drosera node service
After=network-online.target

[Service]
User=$USER
Restart=always
RestartSec=15
LimitNOFILE=65535
ExecStart=$(which drosera-operator) node \\
  --db-file-path %h/.drosera.db \\
  --network-p2p-port 31313 \\
  --server-port 31314 \\
  --eth-rpc-url https://ethereum-hoodi-rpc.publicnode.com \\
  --eth-backup-rpc-url https://ethereum-hoodi-rpc.publicnode.com \\
  --drosera-address 0x91cB447BaFc6e0EA0F4Fe056F5a9b1F14bb06e5D \\
  --eth-private-key $PV_KEY \\
  --listen-address 0.0.0.0 \\
  --network-external-p2p-address $VPS_IP \\
  --disable-dnr-confirmation true \\
  --eth-chain-id 560048

[Install]
WantedBy=multi-user.target
EOF

# ✅ 6. Enable & start new service
sudo systemctl daemon-reload
sudo systemctl enable drosera
sudo systemctl start drosera

echo ""
echo "✅ Drosera node service deployed and started."

# ✅ 7. Register the operator
drosera-operator register \
  --eth-rpc-url https://ethereum-hoodi-rpc.publicnode.com \
  --eth-private-key $PV_KEY \
  --drosera-address 0x91cB447BaFc6e0EA0F4Fe056F5a9b1F14bb06e5D

# ✅ 8. Opt-in to your trap
drosera-operator optin \
  --eth-rpc-url https://ethereum-hoodi-rpc.publicnode.com \
  --eth-private-key $PV_KEY \
  --trap-config-address $TRAP_ADDR

echo ""
echo "============================================"
echo " ✅ All done! Drosera Operator is live! "
echo "============================================"
