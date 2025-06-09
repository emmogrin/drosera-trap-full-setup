#!/bin/bash
set -e

echo "=== Drosera Operator Setup (Connected to Trap) ==="

# Step 1: Move into trap directory
cd ~/my-drosera-trap

# Step 2: Prompt for Operator Public Address
read -p "Enter your OPERATOR_ADDRESS (0x...): " OPERATOR_ADDRESS

# Step 3: Prompt for Drosera private key
read -p "Enter your DROSERA_PRIVATE_KEY (hex, no 0x): " DROSERA_PRIVATE_KEY

# Step 4: Prompt for ETH RPC
read -p "Enter your Ethereum Holesky RPC URL: " ETH_RPC_URL

# Step 5: Prompt for Deployed Trap Contract Address
read -p "Enter your deployed Trap Contract Address (0x...): " TRAP_ADDRESS

# Step 6: Update drosera.toml whitelist with operator and trap address
echo "Updating drosera.toml..."
cp drosera.toml drosera.toml.bak || true

cat > drosera.toml <<TOML
ethereum_rpc = "https://ethereum-holesky-rpc.publicnode.com"
drosera_rpc = "https://relay.testnet.drosera.io"
eth_chain_id = 17000
drosera_address = "0xea08f7d533C2b9A62F40D5326214f39a8E3A32F8"

[traps]
[traps.mytrap]
path = "out/HelloWorldTrap.sol/HelloWorldTrap.json"
response_contract = "0xdA890040Af0533D98B9F5f8FE3537720ABf83B0C"
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

# Step 7: Apply config
DROSERA_PRIVATE_KEY="$DROSERA_PRIVATE_KEY" drosera apply --eth-rpc-url "$ETH_RPC_URL"

# Step 8: Download and install drosera-operator CLI
cd ~
echo "Installing drosera-operator CLI..."
curl -LO https://github.com/drosera-network/releases/releases/download/v1.17.2/drosera-operator-v1.17.2-x86_64-unknown-linux-gnu.tar.gz
tar -xvf drosera-operator-v1.17.2-x86_64-unknown-linux-gnu.tar.gz
sudo cp drosera-operator /usr/bin
drosera-operator --version

# Step 9: Pull Docker image
docker pull ghcr.io/drosera-network/drosera-operator:latest

# Step 10: Register operator
drosera-operator register --eth-rpc-url "$ETH_RPC_URL" --eth-private-key "$DROSERA_PRIVATE_KEY"

# Step 11: Open firewall ports
echo "Configuring UFW..."
sudo ufw allow ssh
sudo ufw allow 22
sudo ufw allow 31313/tcp
sudo ufw allow 31314/tcp
sudo ufw --force enable

# Step 12: Prompt for VPS public IP
read -p "Enter your VPS public IP (for P2P broadcast): " VPS_IP

# Step 13: Create SystemD service
echo "Setting up drosera systemd service..."

sudo tee /etc/systemd/system/drosera.service > /dev/null <<SERVICE
[Unit]
Description=drosera node service
After=network-online.target

[Service]
User=$USER
Restart=always
RestartSec=15
LimitNOFILE=65535
ExecStart=$(which drosera-operator) node --db-file-path $HOME/.drosera.db --network-p2p-port 31313 --server-port 31314 \
    --eth-rpc-url $ETH_RPC_URL \
    --eth-backup-rpc-url https://1rpc.io/holesky \
    --drosera-address 0xea08f7d533C2b9A62F40D5326214f39a8E3A32F8 \
    --eth-private-key $DROSERA_PRIVATE_KEY \
    --listen-address 0.0.0.0 \
    --network-external-p2p-address $VPS_IP \
    --disable-dnr-confirmation true

[Install]
WantedBy=multi-user.target
SERVICE

# Step 14: Start the service
sudo systemctl daemon-reload
sudo systemctl enable drosera
sudo systemctl start drosera

echo "=== All Done! ✅ ==="
echo "Check your node logs with:"
echo "  journalctl -u drosera.service -f"
echo "Then opt in to your trap on https://app.drosera.io/"
