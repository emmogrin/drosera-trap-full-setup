🧡 Drosera Trap Full Setup 🧡

Immortality starts here, Cadet.

This is the official Drosera Trap Full Setup for **PC & VPS**.  
Perfect for serious Cadets running 24/7 nodes, fully automated & secured. ⚔️

> ✨ Saint Khen (@admirkhen) blesses you with immortality.
Claim your Cadet role and rise through the Drosera ranks. 🗡️


---

🧱 What’s to do before proceeding?

Everything you need to first:

📌 Get faucet 🪙 **Get free Hoodi ETH:** [QuickNode Faucet](https://faucet.quicknode.com/ethereum/hoodi/)

📌 **Add Hoodi Testnet to your wallet:** [Chainlist.org](https://chainlist.org/) [tick the include testnet box, and search hoodi.

📌 Get your local IP(Ipv4) this is for those running locally[Check your public IP here](https://whatismyipaddress.com/)

🏅 Comment understand this post on Twitter for free hoodi eth (giveaway)
---


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

😑 Always copy the trap address as indicated below because you'll need it for the next phase
[![IMG-20250703-WA0005.jpg](https://i.postimg.cc/8cB6jc8g/IMG-20250703-WA0005.jpg)](https://postimg.cc/zHvBQJXx)

---

⚙️ Step 2: Setup Drosera Operator
```
./drosera-operator-full.sh
```
📋 You’ll enter:

Your same EVM private key

Your VPS public IP 

Your Trap address

If you run locally get your IP from copy the Ipv4 [Check your public IP here](https://whatismyipaddress.com/)


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
"getDiscordNamesBatch(uint256,uint256)(string[])" \
0 2000 \
--rpc-url https://ethereum-hoodi-rpc.publicnode.com/
```
You should see your username among the output.
[![IMG-20250703-WA0006.jpg](https://i.postimg.cc/76WsS3x8/IMG-20250703-WA0006.jpg)](https://postimg.cc/TLnJ6WLC)

if incase it gives an error try this and enter the cast code again.
```
curl -L https://foundry.paradigm.xyz | bash
source ~/.bashrc
foundryup
```
---
Do this to check general node logs:
```
sudo journalctl -u drosera -f
```

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
