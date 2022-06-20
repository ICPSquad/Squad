# dSquad 🫂

This repository contains all the code for the dSquad project. <br/> It contains 5 canisters that are all deployed on the Internet Computer. <br/> It also contains the assets that compose the collection, some audits that have been perfomed and scripts to help with deployments, testing and configuration.

<img src="assets/others/main-board.jpeg" width="700px">
 
## Requirements
- [x] Avatar **minter** that allow for **customizable** NFT minting, integrate with the <a href="https://github.com/aviate-labs/ext.std" target="_blank"> **EXT** </a> standard and composable with accessories.
- [x] Build the dynamic accessory collection, integrate with the <a href="https://github.com/aviate-labs/ext.std" target="_blank"> **EXT** </a> standard and <a href="https://github.com/Toniq-Labs/entrepot-app" target="_blank"> **Entrepot** </a> marketplace and composable with avatars.
- [x] Integrates [**CAP**](https://cap.ooo) for transaction and mint history for both collections.
- [x] Integrates [**CanisterGeek**](https://cusyh-iyaaa-aaaah-qcpba-cai.raw.ic0.app/) for **monitoring** and **logs** system.
- [x] Compatible with **Plug** and **Stoic** wallets.
- [x] **HTTP** interface for canister informations, asset preview and nft rendering.
- [x] **Invoice** system for processing fees & verification of payments.
- [x] Design of the econony and recipes for accessories with automatic **burning** mechanism.
- [x] Activity tracking system leveraging DAB & CAP.
- [x] Gameplay : scores (daily engagement & style) & missions.
- [x] Leaderboard & reward system.
- [ ] Integrate covercode for code verification.

## Getting started and deploying locally

Make sure you have :

- Dfx installed (>= 0.9.3).
- Node & npm.
- Vessel (Package manager for Motoko) : https://github.com/dfinity/vessel

Run the followings commands to start your replica, install dependencies and deploy the canisters :

```
dfx start --clean
npm install
vessel install
npm run local
```

If you want to upload assets into the canisters run :

```
npm run local:upload
```

## Interact using Node

During the deploy process, a local identity that you can use within node has been set up inside keys/keys.json. <br/>
This identity is automatically set up as admin for all the canisters (expect the ledger).

```
import { fetchIdentity } from "src/node/account";

let identity = fetchIdentity("admin");
console.log("My principal is : " + identity.getPrincipal().toString())
```
