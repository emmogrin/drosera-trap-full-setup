# Drosera Trap Full Setup

Automated scripts to build, deploy, and run your Drosera Trap with Discord immortalization and Operator node setup.

---

## Overview

This repository contains three scripts that simplify the entire Drosera Trap + Operator setup:

- `trap-setup.sh` — Build and deploy your custom Trap contract with your Discord username immortalized on-chain.
- `operator-setup.sh` — Install and launch the Drosera Operator node (supports Docker or SystemD).
- `verify.sh` — Verify that your Discord is immortalized and the Trap contract is registered correctly.

---

## Prerequisites

- A fresh Ubuntu 20.04+ VPS or compatible Linux environment
- Your **Trap EVM private key** (64 hex characters)
- Ethereum RPC URL (Alchemy, QuickNode, or similar for Holesky network)
- GitHub username and email (used for git config during build)
- Your Operator address (`0x...` format)
- VPS public IP (for P2P connections)
- Discord username (e.g. `admirkhen#1234`)

---

## Usage

1. **Clone this repo**

   ```bash
   git clone https://github.com/emmogrin/drosera-trap-full-setup.git
   cd drosera-trap-full-setup
   chmod +x *.sh
   ```
   2. Run Trap setup

This builds and deploys your custom Trap contract:
```
./trap-setup.sh
```

3. Run Operator setup

This installs and starts the Drosera Operator node. You will be prompted to choose between Docker or SystemD:
```
./operator-setup.sh
```

4. Verify your Trap

Check if your Discord is immortalized and Trap is registered:
```
./verify.sh

```


---

How to Confirm It’s Working

After trap-setup.sh, you should see deployment success logs.

The verify.sh script will return true if your address is registered as a responder.

For SystemD, view logs with:

journalctl -u drosera.service -f

For Docker, view logs with:

docker logs -f drosera-node

Visit the Drosera app to connect your wallet and manage your trap.



---

Notes

The scripts automatically install necessary dependencies like Docker, Foundry, Bun, and Drosera CLI.

Make sure your private key and RPC URL are kept secure.

Use SystemD if you want a lightweight, service-managed node. Use Docker if you prefer containerization.

Feel free to edit the scripts to customize parameters.



---

Troubleshooting

If deployment fails, double-check your private key format and RPC URL.

Ensure your VPS firewall allows ports 22, 31313, and 31314.

Check operator logs for errors (journalctl or docker logs).



---

License

MIT License © Saint Khen


---

Made with ❤️ by emmogrin
