#!/bin/bash
set -e

# Trap project folder (adjust if you want)
TRAP_DIR="$HOME/my-drosera-trap"
mkdir -p "$TRAP_DIR"

echo "=== Step 1: Pull Foundry Docker Image ==="
docker pull foundryrs/foundry:latest

echo "=== Step 2: Run container with volume mounted at $TRAP_DIR ==="
docker run --rm -it \
  -v "$TRAP_DIR":/trap \
  -w /trap \
  foundryrs/foundry:latest \
  bash -c "
    # Install Drosera CLI inside container
    curl -L https://app.drosera.io/install | bash
    export PATH=\$HOME/.drosera/bin:\$PATH

    # Install Bun inside container
    curl -fsSL https://bun.sh/install | bash
    export PATH=\$HOME/.bun/bin:\$PATH

    echo '=== Initialize Forge Trap Project ==='
    if [ ! -d 'lib' ]; then
      forge init -t drosera-network/trap-foundry-template
    else
      echo 'Forge project already exists'
    fi

    echo '=== Bun install ==='
    bun install || true

    echo '=== Build contract ==='
    forge build

    echo 'Enter your DROSERA_PRIVATE_KEY (no 0x):'
    read DROSERA_PRIVATE_KEY

    echo 'Enter your ETH RPC URL:'
    read ETH_RPC_URL

    export DROSERA_PRIVATE_KEY
    export ETH_RPC_URL

    echo 'Deploying Trap...'
    drosera apply --eth-rpc-url \$ETH_RPC_URL
  "

echo "=== Done! Your Trap is deployed in $TRAP_DIR ==="
echo "To continue working, rerun this script or enter the container manually:"
echo "docker run --rm -it -v $TRAP_DIR:/trap -w /trap foundryrs/foundry:latest bash"
