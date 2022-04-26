#!/bin/bash

# Those ids are predetermined because the canister id are predictable and always the same when deploying locally.
AVATAR_CANISTER_ID="rrkah-fqaaa-aaaaa-aaaaq-cai"
ACCESSORIES_CANISTER_ID="ryjl3-tyaaa-aaaaa-aaaba-cai"
INVOICE_CANISTER_ID="r7inp-6aaaa-aaaaa-aaabq-cai"
HUB_CANISTER_ID="rkp4c-7iaaa-aaaaa-aaaca-cai"

echo "Creating the canisters 📭"
dfx canister create avatar 
dfx canister create accessories 
dfx canister create invoice 
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
echo "Ids assigned to canisters are correct ✅"

echo "Deploying the module into canisters"
DEPLOYED_HUB_CANISTER_ID=$(dfx canister id hub)
if [ "$DEPLOYED_HUB_CANISTER_ID" != "$HUB_CANISTER_ID" ]; then
    echo "Deployed hub canister id is not the same as the expected one."
    exit 1
fi
echo "Building the WebAssembly modules 👷"
dfx build avatar& > /dev/null 2>&1
dfx build hub& > /dev/null 2>&1
dfx build accessories& > /dev/null 2>&1
dfx build invoice& > /dev/null 2>&1
wait 


echo "Deploying the modules into canisters 🚀"
dfx canister install avatar --mode install --argument "(principal \"${AVATAR_CANISTER_ID}\")"& >> /dev/null 2>&1
dfx canister install accessories --mode install --argument "(principal \"${ACCESSORIES_CANISTER_ID}\", principal \"${AVATAR_CANISTER_ID}\")"& >> /dev/null 2>&1
dfx canister install invoice --mode install& >> /dev/null 2>&1
dfx canister install hub --mode install --argument "(principal \"${HUB_CANISTER_ID}\", principal \"${INVOICE_CANISTER_ID}\", principal \"${AVATAR_CANISTER_ID}\")"& >> /dev/null 2>&1
wait

echo "Giving the admin persmissions to the created identity 🔑"
admin=$(npx ts-node node/tasks/adminId.ts)
dfx canister call avatar add_admin "(principal \"${admin}\")" > /dev/null 2>&1
dfx canister call accessories add_admin "(principal \"${admin}\")" > /dev/null 2>&1
dfx canister call invoice add_admin "(principal \"${admin}\")" > /dev/null 2>&1
dfx canister call hub add_admin "(principal \"${admin}\")" >  /dev/null 2>&1

echo "Uploading assets into avatar & accessory canister (~10 min) 📦"
npx ts-node node/upload/upload-cards.ts& 
bash scripts/upload/upload.sh $AVATAR_CANISTER_ID "local"
wait

echo "Do you also want to upload legendary character (~4 min) [Y/n] "
read input
case $input in 
    [yY][eE][sS]|[yY])
        echo "Uploading legendary character ⭐️"
        bash ./scripts/upload/upload_legendary_characters.sh $canister $network
        ;;
    [nN][oO]|[nN])
        echo "Skipping legendary character"
        ;;
    *)
        echo "Invalid input..."
        exit 1
        ;;
esac

echo "Done 🌈"