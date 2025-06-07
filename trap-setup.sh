#!/bin/bash
set -e

echo "=== Prerequisite: Install Docker ==="
curl -fsSL https://get.docker.com | sh
if ! docker -v &>/dev/null; then
  echo "❌ Docker not installed or not working. Exiting."
  exit 1
fi

echo "=== Step 1: Install Drosera CLI ==="
curl -L https://app.drosera.io/install | bash
source /root/.bashrc
droseraup

echo "=== Step 2: Install Foundry CLI (with Docker fallback) ==="
curl -L https://foundry.paradigm.xyz | bash
source /root/.bashrc
foundryup || true

# Check if `forge` runs, else use Docker wrapper
if ! forge -V &>/dev/null; then
  echo "⚠️ Foundry binaries failed (likely GLIBC error). Using Docker fallback for forge."

  # Create Docker wrapper functions
  cat << 'EOF' > /usr/local/bin/forge
#!/bin/bash
docker run -it --rm -v "$PWD":/app -w /app ghcr.io/foundry-rs/foundry forge "$@"
EOF

  cat << 'EOF' > /usr/local/bin/cast
#!/bin/bash
docker run -it --rm -v "$PWD":/app -w /app ghcr.io/foundry-rs/foundry cast "$@"
EOF

  cat << 'EOF' > /usr/local/bin/anvil
#!/bin/bash
docker run -it --rm -v "$PWD":/app -w /app -p 8545:8545 ghcr.io/foundry-rs/foundry anvil "$@"
EOF

  chmod +x /usr/local/bin/{forge,cast,anvil}
  echo "✅ Docker fallback enabled for Foundry."
else
  echo "✅ Foundry CLI installed and working."
fi

echo "=== Step 3: Install Bun ==="
curl -fsSL https://bun.sh/install | bash
source /root/.bashrc

echo "=== Step 4: Prepare Trap Directory ==="
mkdir -p ~/my-drosera-trap
cd ~/my-drosera-trap

read -p "Enter your Github Email: " GITHUB_EMAIL
read -p "Enter your Github Username: " GITHUB_USER

git config --global user.email "$GITHUB_EMAIL"
git config --global user.name "$GITHUB_USER"

echo "=== Step 5: Initialize Trap Project ==="
forge init -t drosera-network/trap-foundry-template

echo "=== Step 6: Compile Trap ==="
bun install
forge build

echo "=== Step 7: Deploy Trap ==="
read -p "Enter your DROSERA_PRIVATE_KEY (hex, no 0x prefix): " DROSERA_PRIVATE_KEY
read -p "Enter your Ethereum RPC URL (e.g. Holesky): " ETH_RPC_URL

DROSERA_PRIVATE_KEY="$DROSERA_PRIVATE_KEY" drosera apply --eth-rpc-url "$ETH_RPC_URL"

echo "=== Step 8: Existing User Trap Address Setup (optional) ==="
read -p "Are you an existing user needing to add trap address? (y/N): " EXISTING_USER
if [[ "$EXISTING_USER" =~ ^[Yy]$ ]]; then
  read -p "Enter your TRAP_ADDRESS (0x...): " TRAP_ADDRESS
  read -p "Enter your whitelist operator addresses separated by commas (Operator1_Address,Operator2_Address,...): " WHITELIST
  echo "" >> drosera.toml
  echo "address = \"$TRAP_ADDRESS\"" >> drosera.toml
  IFS=',' read -ra ADDRS <<< "$WHITELIST"
  printf 'whitelist = [\n' >> drosera.toml
  for addr in "${ADDRS[@]}"; do
    printf '  "%s",\n' "$addr" >> drosera.toml
  done
  printf ']\n' >> drosera.toml

  DROSERA_PRIVATE_KEY="$DROSERA_PRIVATE_KEY" drosera apply --eth-rpc-url "$ETH_RPC_URL"
fi

echo "=== Step 9: Check Trap on Dashboard ==="
echo "Visit https://app.drosera.io/ and connect your Drosera EVM wallet."
echo "Click on 'Traps Owned' or search your Trap address."

echo "=== Step 10: Bloom Boost Trap ==="
echo "Open your Trap on Dashboard and click 'Send Bloom Boost' to deposit some Holesky ETH."

echo "=== Step 11: Fetch Blocks (dryrun) ==="
drosera dryrun

echo "=== Setup Complete ==="
