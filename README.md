
🧡 Drosera Trap Full Setup Guide 🧡

Immortality starts here, Cadet.

Welcome to the official Drosera Trap Full Setup repo.

> ✨ Saint Khen (@admirkhen) blesses you with immortality.
Claim your Cadet role and rise through the Drosera ranks. ⚔️




---

🧱 What’s This?

A one-stop setup to:

🧲 Deploy your first Trap

🧑‍💻 Setup Drosera Operator

🔗 Immortalize your Discord username on-chain

🏅 Earn the Cadet Role in Discord



---

📁 Scripts in This Repo

File	Purpose

trap-setup.sh	Deploy your first Trap (do this first)
drosera-operator-full.sh	Setup Drosera Operator (to run your trap)
immortalize_discord.sh	Immortalize your Discord username on-chain
verify.sh	Verify if you’re immortalized (optional)
drosera.toml	Config file (auto-edited by scripts)



---

⚙️ Setup Instructions (Ubuntu VPS Recommended)

🪜 Step 0: Clone the Repo
```
apt update && apt install -y git
git clone https://github.com/emmogrin/drosera-trap-full-setup.git
cd drosera-trap-full-setup
```

---

🐳 Step 1: Install Docker & Dependencies

(Skip if Docker is already installed)
```
chmod +x install-docker.sh
./install-docker.sh
```

---

🧲 Step 2: Deploy Your Trap
```
chmod +x trap-setup.sh
./trap-setup.sh
```
What you'll enter:

Your GitHub email

Your GitHub username

Your Holesky EVM private key (0.2 ETH recommended)

Your Ethereum Holesky RPC (e.g., from Alchemy)


🟠 If you're a new user, choose No when asked if you're existing.

🚨 After deploying, go to https://app.drosera.io and Bloom your Trap to activate it.


---

⚙️ Step 3: Setup Drosera Operator
```
chmod +x drosera-operator-full.sh
./drosera-operator-full.sh
```
You'll be asked for:

Operator address

Same private key

Holesky RPC

Your Trap address (from the previous step)


✅ Once done, go opt-in on the website.
🧠 Use OKX Wallet — Metamask might bug out.


---

🪪 Step 4: Immortalize Your Discord Username
```
chmod +x immortalize_discord.sh
./immortalize_discord.sh
```
Enter:

Your Discord username (e.g., admirkhen#1234)

Same private key

your VPS IP

your RPC URL 

🎖️ Once done, your name is on-chain. You’re now a Cadet.


---

✅ Step 5: Verify Your Immortality (Optional)

source ~/.bashrc  # ✅ For correct env setup
```
cast call 0x4608Afa7f277C8E0BE232232265850d1cDeB600E \
"isResponder(address)(bool)" \
0xYourWalletAddress \
--rpc-url https://ethereum-holesky-rpc.publicnode.com/
```
If it returns true → You’re immortal 🧬


---

🔍 View All Immortalized Discords
```
cast call 0x4608Afa7f277C8E0BE232232265850d1cDeB600E \
"getDiscordNamesBatch(uint256,uint256)(string[])" \
0 2000 \
--rpc-url https://ethereum-holesky-rpc.publicnode.com/

```
---

💡 Tips & Requirements

Use a VPS with at least 2GB RAM

Fund your EVM wallet with Holesky ETH

Get from holeskyfaucet.com


Scripts are idempotent — rerun anytime

Always use OKX Wallet on the dashboard



---

👑 Credits

Built by Saint Khen
🧡 Twitter: @admirkhen
🔥 Thanks to 0xmoei for the Drosera wizardry.

> Saint Khen blesses you with immortality.
Go forth and claim your Cadet role ⚔️




---

🗣 Questions or Stuck?

DM @admirkhen
Or hop in the Drosera Discord


