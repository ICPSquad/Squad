# ICP Squad 🫂

This repository contains all the code for the ICP Squad project. <br/> It contains 5 canisters that are all deployed on the Internet Computer. <br/> It also contains the assets that compose the collection, some audits that have been perfomed and scripts to help with deployments, testing and configuration.

<img src="assets/others/main-board.jpeg" width="700px">
 
## Requirements
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

## Checking your balance and making ICP transfer using the ledger

During the deploy process, when the local ledger is set : 100 ICP are automatically minted to your ledger address id. You can check you balance and initate transfer using dfx. <br/>

(Unfortunately there a currently no ways to use Plug or Stoic locally)

- Checking your balance.

```
export LEDGER_ACC=$(dfx ledger account-id)
dfx canister call ledger account_balance '(record { account = '$(python3 -c 'print("vec{" + ";".join([str(b) for b in bytes.fromhex("'$LEDGER_ACC'")]) + "}")')' })'
```

- Make a transfer to an account.

  - Get the textual representation of the AccountIdentifier you wanna send funds to.

    - You can use this tool to convert a principal to an account id : https://k7gat-daaaa-aaaae-qaahq-cai.ic0.app/docs/. <br/>
    - You can also use the node script called account.ts.

  - Transform the account identifier to a 32-bytes blob.

  ```
  dfx canister call invoice accountIdentifierToBlob "(variant {"text" = "<YOUR_ACCOUNT>" })"
  ```

  - Send the update call to the ledger.

  ```
  dfx canister call ledger transfer '( record { memo = 0; amount = record { e8s = 10_000_000_000 }; fee = record { e8s = 10000 }; to = blob "<YOUR_BLOB>" })'
  ```
