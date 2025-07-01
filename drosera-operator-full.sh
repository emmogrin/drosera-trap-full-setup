#!/bin/bash
set -e

echo "==============================================="
echo "🔺 UCHIHA SAINT OPERATOR NODE SETUP FOR HOODI 🔺"
echo "==============================================="

# 1. Move into trap folder
cd ~/my-drosera-trap

# 2. Prompt
read -p "Enter your OPERATOR_ADDRESS (0x...): " OPERATOR_ADDRESS
read -p "Enter your DROSERA_PRIVATE_KEY (hex, no 0x): " DROSERA_PRIVATE_KEY
read -p "Enter your Ethereum RPC URL (Hoodi): " ETH_RPC_URL
read -p "Enter your Deployed Trap Contract Address: " TRAP_ADDRESS

# 3. Update TOML
echo "Updating drosera.toml..."
cp drosera.toml drosera.toml.bak || true

cat > drosera.toml <<TOML
ethereum_rpc = "$ETH_RPC_URL"
drosera_rpc = "https://relay.hoodi.drosera.io"
eth_chain_id = 560048
drosera_address = "0x91cB447BaFc6e0EA0F4Fe056F5a9b1F14bb06e5D"

[traps]
[traps.mytrap]
path = "out/HelloWorldTrap.sol/HelloWorldTrap.json"
response_contract = "0x183D78491555cb69B68d2354F7373cc2632508C7"
response_function = "helloworld(string)"
cooldown_period_blocks = 33
min_number_of_operators = 1
max_number_of_operators = 2
block_sample_size = 10
private_trap = true
whitelist = ["$OPERATOR_ADDRESS"]
address = "$TRAP_ADDRESS"
TOML

echo "drosera.toml updated ✅"

# 4. Confirm or Skip drosera apply  optional:
# echo "Applying config..."
# DROSERA_PRIVATE_KEY="$DROSERA_PRIVATE_KEY" drosera apply --eth-rpc-url "$ETH_RPC_URL"

# 5. Download & Install Operator CLI
cd ~
echo "Installing drosera-operator CLI..."
curl -LO https://github.com/drosera-network/releases/releases/download/v1.17.2/drosera-operator-v1.17.2-x86_64-unknown-linux-gnu.tar.gz
tar -xvf drosera-operator-v1.17.2-x86_64-unknown-linux-gnu.tar.gz
sudo cp drosera-operator /usr/bin
drosera-operator --version

# 6. Pull Docker image
docker pull ghcr.io/drosera-network/drosera-operator:latest

# 7. Register Operator
drosera-operator register --eth-rpc-url "$ETH_RPC_URL" --eth-private-key "$DROSERA_PRIVATE_KEY" --drosera-address 0x91cB447BaFc6e0EA0F4Fe056F5a9b1F14bb06e5D

# 8. Firewall
echo "Configuring UFW..."
sudo ufw allow ssh
sudo ufw allow 22
sudo ufw allow 31313/tcp
sudo ufw allow 31314/tcp
sudo ufw --force enable

# 9. VPS Public IP
read -p "Enter your VPS public IP for P2P: " VPS_IP

# 10. SystemD Service
echo "Setting up drosera systemd service..."
sudo tee /etc/systemd/system/drosera.service > /dev/null <<SERVICE
[Unit]
Description=Drosera Operator Node
After=network-online.target

[Service]
User=$USER
Restart=always
RestartSec=15
LimitNOFILE=65535
ExecStart=$(which drosera-operator) node --db-file-path $HOME/.drosera.db --network-p2p-port 31313 --server-port 31314 \
    --eth-rpc-url $ETH_RPC_URL \
    --eth-backup-rpc-url https://eth-hoodi.g.alchemy.com/v2/SDctBqvoTyj4LBriVGJPE \
    --drosera-address 0xea08f7d533C2b9A62F40D5326214f39a8E3A32F8 \
    --eth-private-key $DROSERA_PRIVATE_KEY \
    --listen-address 0.0.0.0 \
    --network-external-p2p-address $VPS_IP \
    --disable-dnr-confirmation true

[Install]
WantedBy=multi-user.target
SERVICE

# 11. Start Service
sudo systemctl daemon-reload
sudo systemctl enable drosera
sudo systemctl start drosera

echo "✅ Operator Node Ready! Uchiha Saint Approves. 🔺"
echo "Check logs:  journalctl -u drosera.service -f"
echo "Then opt in your operator: https://app.drosera.io/"
