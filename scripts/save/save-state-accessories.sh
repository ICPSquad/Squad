#!/bin/bash

echo "Saving the state of the accessory canister"

mkdir -p data/$(date +%Y-%m-%d)/accessories

dfx canister --network ic call accessories getTemplates >> data/$(date +%Y-%m-%d)/accessories/templates.txt
dfx canister --network ic call accessories getItems >> data/$(date +%Y-%m-%d)/accessories/items.txt
dfx canister --network ic call accessories getRegistry >> data/$(date +%Y-%m-%d)/accessories/registry.txt
