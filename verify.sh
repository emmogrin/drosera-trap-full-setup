#!/bin/bash

echo -e "\n=== 🔍 Drosera Trap Verification ==="

read -p "Enter your Private Key: " PRIVATE_KEY
read -p "Enter your RPC URL: " RPC_URL

OWNER_ADDR=$(cast wallet address --private-key $PRIVATE_KEY)
cast call 0x4608Afa7f277C8E0BE232232265850d1cDeB600E "isResponder(address)(bool)" $OWNER_ADDR --rpc-url "$RPC_URL"
