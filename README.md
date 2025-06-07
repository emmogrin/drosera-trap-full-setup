# 🧡🧡🧡🧡🧡🧡 Drosera Trap Full Setup🧡🧡🧡🧡🧡🧡🧡🧡

Welcome to the official **Drosera Trap Full Setup** repo.

# Saint Khen (@admirkhen) blesses you with immortality.  
Go forth and earn your **Cadet role** on Discord 🛡️

---

## 🧱 What Is This?

This repo helps you:

- ✅ Deploy your first Trap (must be done first)
- 🧑‍💻 Setup Drosera Operator (depends on trap being deployed)
- 🔗 Immortalize your Discord username on-chain
- 🏅 Earn the exclusive **Cadet role**

---

## 📁 Files🧡

| Script | Purpose |
|--------|---------|
| `trap-setup.sh`            | Deploy your first Trap (required before operator) |
| `drosera-operator-full.sh` | Setup Drosera Operator (runs the trap) |
| `immortalize_discord.sh`   | Submit your Discord username and get Cadet role |
| `verify.sh`                | Check if Discord name is on-chain |
| `drosera.toml`             | Config file (auto-edited by scripts) |

---

# 🚀 Full Setup Guide (Ubuntu VPS)

# 0. Clone the repo
```bash
git clone https://github.com/emmogrin/drosera-trap-full-setup.git
cd drosera-trap-full-setup
```
# 1. install docker and dependencies (skip if Docker and dependencies already installed)
```
chmod +x install-docker.sh
./install-docker.sh
```
# 2. Deploy your Trap 
```
chmod +x trap-setup.sh
./trap-setup.sh
```


# 3. Setup Drosera Operator (after trap is deployed)
```
chmod +x drosera-operator-full.sh
./drosera-operator-full.sh
```

# 4. Immortalize your Discord Name (earn Cadet role)
```
chmod +x immortalize_discord.sh
./immortalize_discord.sh
```

⚠️ You need your EVM private key and some Holesky ETH
Get ETH from: https://holeskyfaucet.com



✅ Verify Immortality
```
source /root/.bashrc


cast call 0x4608Afa7f277C8E0BE232232265850d1cDeB600E \
"isResponder(address)(bool)" \
0xYourWalletAddress \
--rpc-url https://ethereum-holesky-rpc.publicnode.com/
```
Returns true = Discord username is immortalized on-chain 🔥
---


📜 View All Immortalized Discord Names
```
source /root/.bashrc

cast call 0x4608Afa7f277C8E0BE232232265850d1cDeB600E \
"getDiscordNamesBatch(uint256,uint256)(string[])" \
0 2000 \
--rpc-url https://ethereum-holesky-rpc.publicnode.com/
```


👑 Credits

Created by Saint Khen
Follow for more: @admirkhen

> Saint Khen blesses you with immortality.
Go forth and claim your Cadet role ⚔️

thanks to 0xmoei🔥



---

💡 Tips

Use a VPS with at least 2GB RAM

Fund your wallet with Holesky ETH before deploying traps

Scripts are idempotent — rerun if needed



---

🗣 Questions?

DM @admirkhen or hop on Discord.
Stay immortal.


