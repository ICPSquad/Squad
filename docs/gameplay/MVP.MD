# ICP Squad : Supernova & MVP.

This document will outline the expected requirements for ICPSquad that will be submitted for the **Supernova** hackathon and as the **MVP**.

Timeline : June 2022.

## Avatar

The avatar minter should be built and fully functionnal.

Allow any user with a wallet (Plug or Stoic) to log in, pay 1 ICP and mint a fully customizable avatar. <br/>
Once the minting process is done, the avatar is automatically generated, minted and received in the wallet.

Backend :

- [x] EXT standard
- [x] Wallet integration : Stoic & Plug.
- [x] CAP integration
- [x] Avatar minter
- [x] Assets management
- [x] Fully customizable minting
- [x] Dynamic redrawing of the avatar when equipped/desequipped accessory.

Frontend :

- [ ] Homepage
- [ ] Minter : user can try out the different customization option, log in with they wallet when they want to mint and pay 1 ICP to confirm and receive the avatar in their wallet.
- [ ] Room : user can equip and desequip the accessories that they own in their wallet.

## Accessories

The accessory minter should be built and fully functionnal.

Allow any user with a wallet (Plug or Stoic) to log in, pay the **minting fee** (currently fixed at 0.5 ICP) and mint one of the available accessory by combining his available materials.

Backend :

- [x] EXT standard.
- [x] Entrepot integration.
- [x] CAP integration.
- [x] Accessory minter using materials.
- [ ] Assets management.
- [ ] Dynamic update and automatic burning.
- [ ] Communication with the avatar canister to redraw the avatar when an accessory is equipped/desequipped.
- [ ] Integration with branded accessories.
- [ ] Integration with legendary accessories.

Frontend :

- [ ] Accessory shop : user can combine his materials and pay the minting fee (0.5 ICP) to create a fresh accessory.

## Gameplay : score, missions, leaderboard & airdrop.

Backend :

- [ ] Calculate **style** score based on the accessory the avatar is wearing.
- [ ] Calculate **engagement** score on the missions & the engagement with other apps.
- [ ] Mix the two [scores](SCORES.MD) to calculate the ranking of each avatar and output the **leaderboard**.
- [ ] Airdrop : monthly prizes should be automatically airdropped
- [ ] At the end of each month a **prize pool** is airdropped to all users based on their ranking for this month and a randomn factor.
- [ ]
- [ ]

- Display the prize pool and its corresponding value in $.
- Create a transparent airdrop mechanism that will automatically be executed.
