#!/bin/bash

# Those ids are predetermined because the canister id are predictable and always the same when deploying locally.
AVATAR_CANISTER_ID="rrkah-fqaaa-aaaaa-aaaaq-cai"
ACCESSORIES_CANISTER_ID="r7inp-6aaaa-aaaaa-aaabq-cai"
INVOICE_CANISTER_ID="rkp4c-7iaaa-aaaaa-aaaca-cai"
HUB_CANISTER_ID="rno2w-sqaaa-aaaaa-aaacq-cai"

dfx start --clean --background
dfx deploy avatar --argument "(principal \"${AVATAR_CANISTER_ID}\")"
DEPLOYED_AVATAR_CANISTER_ID=$(dfx canister id avatar)
if [ "$DEPLOYED_AVATAR_CANISTER_ID" != "$AVATAR_CANISTER_ID" ]; then
    echo "Deployed avatar canister id is not the same as the expected one."
    exit 1
fi
dfx deploy accessories --argument "(principal \"${ACCESSORIES_CANISTER_ID}\", principal \"${AVATAR_CANISTER_ID}\")"
DEPLOYED_ACCESSORIES_CANISTER_ID=$(dfx canister id accessories)
if [ "$DEPLOYED_ACCESSORIES_CANISTER_ID" != "$ACCESSORIES_CANISTER_ID" ]; then
    echo "Deployed accessories canister id is not the same as the expected one."
    exit 1
fi
dfx deploy invoice 
DEPLOYED_INVOICE_CANISTER_ID=$(dfx canister id invoice)
if [ "$DEPLOYED_INVOICE_CANISTER_ID" != "$INVOICE_CANISTER_ID" ]; then
    echo "Deployed invoice canister id is not the same as the expected one."
    exit 1
fi
dfx deploy hub --argument "(principal \"${HUB_CANISTER_ID}\", principal \"${INVOICE_CANISTER_ID}\", principal \"${AVATAR_CANISTER_ID}\")"
DEPLOYED_HUB_CANISTER_ID=$(dfx canister id hub)
if [ "$DEPLOYED_HUB_CANISTER_ID" != "$HUB_CANISTER_ID" ]; then
    echo "Deployed hub canister id is not the same as the expected one."
    exit 1
fi
admin=$(npx ts-node node/tasks/adminId.ts)
echo "All canisters have been deployed."

echo "Adding (created) admin user"
dfx canister call avatar add_admin "(principal \"${admin}\")" 
dfx canister call accessories add_admin "(principal \"${admin}\")" 
dfx canister call invoice add_admin "(principal \"${admin}\")" 
dfx canister call hub add_admin "(principal \"${admin}\")" 

