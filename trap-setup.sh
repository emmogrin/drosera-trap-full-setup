#!/bin/bash
set -e

echo "───────────────────────────────────────────────"
echo "   🪤 DROSERA TRAP SETUP - by @admirkhen"
echo "───────────────────────────────────────────────"

read -p "Enter your EVM private key (hex, no 0x prefix): " PRIV_KEY

if [[ -z "$PRIV_KEY" ]]; then
  echo "Private key cannot be empty!"
  exit 1
fi

# Add 0x prefix if missing
if [[ $PRIV_KEY != 0x* ]]; then
  PRIV_KEY="0x$PRIV_KEY"
fi

# Clone trap repo
echo "Cloning Drosera trap starter repo..."
git clone https://github.com/drosera-network/trap-starter.git my-drosera-trap

cd my-drosera-trap

# Compile trap contract
echo "Compiling trap contract..."
forge build

# Test the trap before deploying
echo "Running dryrun test..."
drosera dryrun

# Deploy trap contract
echo "Deploying trap to Holesky testnet..."
DROSERA_PRIVATE_KEY=$PRIV_KEY drosera apply

echo ""
echo "───────────────────────────────────────────────"
echo "✅ Trap deployed successfully!"

echo "⚠️ IMPORTANT: To activate your Trap fully:"
echo "1) Open the Drosera Dashboard: https://dashboard.drosera.io"
echo "2) Go to 'Traps Owned' and find your Trap."
echo "3) Click 'Send Bloom Boost' and deposit some Holesky ETH to your Trap."
echo "4) Then come back here and run 'drosera dryrun' to fetch and simulate blocks."

echo "You can run this command anytime to test your Trap:"
echo "drosera dryrun"
echo "───────────────────────────────────────────────"
