# ICP Squad 🫂

This repository contains all the code for the ICP Squad project. <br/> It contains 5 canisters that are all deployed on the Internet Computer. <br/> It also contains the assets that compose the collection, some audits that have been perfomed and scripts to help with deployments, testing and configuration.

Goals ✅

- [x] Avatar **minter** that allow for **customizable** NFT minting, integrate with the <a href="https://github.com/aviate-labs/ext.std" target="_blank"> **EXT** </a> standard and composable with accessories.
- [x] Build the dynamic accessory collection, integrate with the <a href="https://github.com/aviate-labs/ext.std" target="_blank"> **EXT** </a> standard and <a href="https://github.com/Toniq-Labs/entrepot-app" target="_blank"> **Entrepot** </a> marketplace and composable with avatars.
- [x] Integrates [**CAP**](https://cap.ooo) for transaction and mint history for both collections.
- [x] Integrates [**CanisterGeek**](https://cusyh-iyaaa-aaaah-qcpba-cai.raw.ic0.app/) for **monitoring** and **logs** system.
- [x] Compatible with **Plug** and **Stoic** wallets.
- [x] **HTTP** interface for canister informations, asset preview and nft rendering.
- [x] **Invoice** system for live and open minting in exchange of 1 ICP.
- [ ] Finish the econony and early gameplay planning.
- [ ] Drainining and restoring state of all canister at any point to allow for backup system.
- [ ] Mission, gameplay, airdrop and bootcamp integration.
- [ ] Legendaries accessories and characters integration.
- [ ] Dynamic algorithm for accessory resizing and equipment.
- [ ] DAO wallet than can hold and distribute tokens and NFTs of multiple standards to the squad.
- [ ] Integrate covercode.oo for code verification.
- [ ] Multi-season and collection architecture.

## Invoice

Canister : **if27l-eyaaa-aaaaj-qaq5a-cai** <br/>
Candid interface : https://a4gq6-oaaaa-aaaab-qaa4q-cai.raw.ic0.app/?id=if27l-eyaaa-aaaaj-qaq5a-cai

This canister is directly inspired from the Invoice canister by Dfinity.
Any canister can receive a request to purchase, create an invoice and store the Principal and the UUID of the invoice.
The invoice canister abstracts away the NNS ledger complexity and allow the canister to chjck at any point the status of the payment with **verify_invoice**.

Goals ✅

- [x] Allow for invoice management for all needs.
- [ ] Integrates [**CanisterGeek**](https://cusyh-iyaaa-aaaah-qcpba-cai.raw.ic0.app/) for **monitoring** and **logs** system.
- [ ] Integrate covercode.oo for code verification.

More details.

## Hub

Canister id : **p4y2d-yyaaa-aaaaj-qaixa-cai** <br/>
Candid interface : https://a4gq6-oaaaa-aaaab-qaa4q-cai.raw.ic0.app/?id=p4y2d-yyaaa-aaaaj-qaixa-cai

This canister is responsible for the registration interface, keeping track of user data, cronic tasks and handling ICPs.

Goals ✅

- [x] Interface with the invoice canister for registration.
- [x] Cronic tasks to send recipe of the week, run some audits and collect metrics by calling other canisters.
- [ ] Integrates [**CanisterGeek**](https://cusyh-iyaaa-aaaah-qcpba-cai.raw.ic0.app/) for **monitoring** and **logs** system.
- [ ] Gameplay functionnalities (airdrop, missions, scores...).

More details.

## Avatar

Canister id : **jmuqr-yqaaa-aaaaj-qaicq-cai** <br/>
Candid interface : https://a4gq6-oaaaa-aaaab-qaa4q-cai.raw.ic0.app/?id=jmuqr-yqaaa-aaaaj-qaicq-cai

This canister is the home of the avatar nft collection.

Goals ✅

TODO

More details.

## Accessory

Canister id : **po6n2-uiaaa-aaaaj-qaiua-cai** <br/>
Candid interface : https://a4gq6-oaaaa-aaaab-qaa4q-cai.raw.ic0.app/?id=po6n2-uiaaa-aaaaj-qaiua-cai

This canister is the home of the accessory nft collection.

Goals ✅

TODO

More details.

## Website

URL : https://p3z4x-vaaaa-aaaaj-qaixq-cai.ic0.app/

This canister is simply a frontend canister deployed on the IC. The website is built using VueJS, Typescript & Tailwind.

TODO : add website requirements.

## Deploying locally and contributing

- Start your local replica and deploy the avatar canister first, then deploy the rest of the fleet.

```
dfx start --clean
dfx deploy avatar --argument("rrkah-fqaaa-aaaaa-aaaaq-cai")
dfx deploy
```

- Upload assets and setup configuration.

```

```

## Backup

TODO
