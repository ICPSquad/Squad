#!/bin/bash

# Those ids are predetermined because the canister id are predictable and always the same when deploying locally.
AVATAR_CANISTER_ID="rrkah-fqaaa-aaaaa-aaaaq-cai"
ACCESSORIES_CANISTER_ID="ryjl3-tyaaa-aaaaa-aaaba-cai"
INVOICE_CANISTER_ID="r7inp-6aaaa-aaaaa-aaabq-cai"
LEDGER_CANISTER_ID="rkp4c-7iaaa-aaaaa-aaaca-cai"
HUB_CANISTER_ID="rno2w-sqaaa-aaaaa-aaacq-cai"

echo "Using your default identity 👦"
dfx identity use default

echo "Creating the canisters 📭"
dfx canister create avatar 
dfx canister create accessories 
dfx canister create invoice 
dfx canister create ledger
dfx canister create hub

echo "Verifying the ids assigned to canisters 🔍"
DEPLOYED_AVATAR_CANISTER_ID=$(dfx canister id avatar)
if [ "$DEPLOYED_AVATAR_CANISTER_ID" != "$AVATAR_CANISTER_ID" ]; then
    echo "Deployed avatar canister id is not the same as the expected one."
    exit 1
fi
DEPLOYED_ACCESSORIES_CANISTER_ID=$(dfx canister id accessories)
if [ "$DEPLOYED_ACCESSORIES_CANISTER_ID" != "$ACCESSORIES_CANISTER_ID" ]; then
    echo "Deployed accessories canister id is not the same as the expected one."
    exit 1
fi
DEPLOYED_INVOICE_CANISTER_ID=$(dfx canister id invoice)
if [ "$DEPLOYED_INVOICE_CANISTER_ID" != "$INVOICE_CANISTER_ID" ]; then
    echo "Deployed invoice canister id is not the same as the expected one."
    exit 1
fi
DEPLOYED_LEDGER_CANISTER_ID=$(dfx canister id ledger)
if [ "$DEPLOYED_LEDGER_CANISTER_ID" != "$LEDGER_CANISTER_ID" ]; then
    echo "Deployed ledger canister id is not the same as the expected one."
    exit 1
fi
DEPLOYED_HUB_CANISTER_ID=$(dfx canister id hub)
if [ "$DEPLOYED_HUB_CANISTER_ID" != "$HUB_CANISTER_ID" ]; then
    echo "Deployed hub canister id is not the same as the expected one."
    exit 1
fi

echo "Building the WebAssembly modules 👷"
dfx build avatar& > /dev/null 2>&1
dfx build accessories& > /dev/null 2>&1
dfx build invoice& > /dev/null 2>&1
dfx build hub& > /dev/null 2>&1
wait 


echo "Deploying the modules into canisters 🚀"
dfx canister install avatar --mode install --argument "(principal \"${AVATAR_CANISTER_ID}\", principal \"${ACCESSORIES_CANISTER_ID}\", principal \"${INVOICE_CANISTER_ID}\", principal \"${HUB_CANISTER_ID}\")"
dfx canister install accessories --mode install --argument "(principal \"${ACCESSORIES_CANISTER_ID}\", principal \"${AVATAR_CANISTER_ID}\", principal \"${INVOICE_CANISTER_ID}\", principal \"${LEDGER_CANISTER_ID}\", principal \"${HUB_CANISTER_ID}\")"
dfx canister install invoice --mode install --argument "(principal \"${LEDGER_CANISTER_ID}\", principal \"${AVATAR_CANISTER_ID}\", principal \"${ACCESSORIES_CANISTER_ID}\", null, null)" 
dfx canister install hub --mode install --argument "(principal \"${HUB_CANISTER_ID}\", principal \"${INVOICE_CANISTER_ID}\", principal \"${AVATAR_CANISTER_ID}\")"
wait

echo "Deploying the ledger 💰"
sed -i "" 's/public.did/private.did/' dfx.json
dfx identity new minter 
dfx identity use minter
export MINT_ACC=$(dfx ledger account-id)
dfx identity use default 
export LEDGER_ACC=$(dfx ledger account-id)
dfx deploy ledger --argument "(record {minting_account = \"${MINT_ACC}\"; initial_values = vec { record { \"${LEDGER_ACC}\"; record { e8s=100_000_000_000 } }; }; send_whitelist = vec {}})" >> /dev/null 2>&1
sed -i "" 's/private.did/public.did/' dfx.json

echo "Giving the admin permissions to the identity (node) 🔑"
admin=$(npx ts-node node/tasks/adminId.ts)
dfx canister call avatar add_admin "(principal \"${admin}\")" > /dev/null 2>&1
dfx canister call accessories add_admin "(principal \"${admin}\")" > /dev/null 2>&1
dfx canister call invoice add_admin "(principal \"${admin}\")" > /dev/null 2>&1

echo "All canisters have been deployed."