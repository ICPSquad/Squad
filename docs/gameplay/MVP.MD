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
- [ ] Dynamic update and automatic burning.
- [ ] Communication with the avatar canister to redraw the avatar when an accessory is equipped/desequipped.
- [ ] Integration with branded accessories.
- [ ] Integration with legendary accessories.

Frontend :

- [ ] Accessory shop/minter : user can combine his materials and pay the minting fee (0.5 ICP) to create a fresh accessory.

## Gameplay : score, missions, leaderboard & airdrop.

Backend :

- [ ] Design and document the concept of mission : how to start one, how to validate one, what are the rewards...
- [ ] Design and document the two Open Internet Services that will power the gameplay : score and missions.
- [ ] Calculate **style** score based on the accessory the avatar is wearing.
- [ ] Calculate **engagement** score based on both the missions & the engagement with other apps.
- [ ] Mix the two [scores](SCORES.MD) to calculate the ranking of each avatar and output the **leaderboard**.
- [ ] Algorithm : Design the algorithm to airdrop prizes to people based on their rank, need to be fair and fun and respect the specifications we described in the [economy](ECONOMY.MD).
- [ ] Airdrop : monthly prizes should be automatically airdropped.

Frontend :

- [ ] User profile : display the avatar and it's current score, access to airdrops and (in the future) more options to customize the avatar (name, status)...
- [ ] Leaderboard : TODO.
- [ ] Mission board : TODO.
