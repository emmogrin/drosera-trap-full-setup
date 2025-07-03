🧡 Drosera Trap Full Setup 🧡

Immortality starts here, Cadet.

This is the official Drosera Trap Full Setup for **PC & VPS**.  
Perfect for serious Cadets running 24/7 nodes, fully automated & secured. ⚔️

> ✨ Saint Khen (@admirkhen) blesses you with immortality.
Claim your Cadet role and rise through the Drosera ranks. 🗡️


---

🧱 What’s Inside?

Everything you need to:

📌 Deploy your first Trap (Hoodi)

📌 Setup your Drosera Operator on VPS/PC

📌 Immortalize your Discord username on-chain

🏅 Earn your Cadet Rank


---

📂 Scripts Included

| File | Purpose |
| ---- | ------- |
| `trap-setup.sh` | Deploy your Trap |
| `drosera-operator-full.sh` | Setup Drosera Operator (systemd) |
| `immortalize_discord.sh` | Immortalize your Discord name |
| `verify.sh` | Optional — check if immortal |
| `drosera.toml` | Config (auto-edited by scripts) |


---

⚙️ Setup Instructions (Ubuntu VPS or PC)

🪜 **Step 0: Clone this repo**

```bash
sudo apt update && sudo apt install -y git
```
```
git clone https://github.com/emmogrin/drosera-trap-full-setup.git
cd drosera-trap-full-setup
chmod +x *.sh
```

---

🐳 Step 1: Deploy Your Trap
```
./trap-setup.sh
```
📋 What you’ll enter:

Your GitHub email

Your GitHub username

Your EVM private key (funded)

Your Ethereum Hoodi RPC URL


🚨 New users: Leave the address line commented — the script handles it.

✅ Bloomboost your Trap on https://app.drosera.io if needed.


---

⚙️ Step 2: Setup Drosera Operator
```
./drosera-operator-full.sh
```
📋 You’ll enter:

Your same EVM private key

Your VPS public IP

Your Trap address


🔒 This sets up the systemd service for auto-start.

if you don't see green ticks on your liveness dashboard (enter this)
```
sudo systemctl daemon-reload
sudo systemctl restart drosera
sudo journalctl -u drosera -f
```


---

🕊️ Step 3: Immortalize Your Discord
```
./immortalize_discord.sh
```
📋 You’ll enter:

Your Discord username (e.g. admirkhen#1234)

Same private key

Your Hoodi RPC URL


✅ You’re immortal! Claim your Cadet Role.


---

✅ Step 4 (Optional): Verify Immortality
```
source ~/.bashrc
```
```
cast call 0x25E2CeF36020A736CF8a4D2cAdD2EBE3940F4608 \
"isResponder(address)(bool)" \
0xYOURWALLETADDRESS \
--rpc-url https://ethereum-hoodi-rpc.publicnode.com/

```
---

💡 Tips

✔️ Use a clean Ubuntu VPS (2GB+ RAM)

✔️ Fund your wallet with enough Hoodi ETH

✔️ Scripts are idempotent — run anytime

✔️ Always Bloomboost your Trap!


---

👑 Credits

Saint Khen 🧡 Twitter: @admirkhen
Big thanks to the Drosera Guild ⚡

> Saint Khen watches over you. Go claim your Cadet rank, forever. ⚔️




---

🗣 Stuck?

DM @admirkhen
Or hop in the Drosera Discord.
