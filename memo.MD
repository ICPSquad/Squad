# Users & Avatar

## Users

Users are authenticated through their Principal; ie the Principal of the wallet they use to log in (Plug or Stoic).
We moved away from Internet Identity as it doesn't allow cross-app tracking which is necessayr for the gameplay.

Each user has a profile; which contains different informations such as Twitter/Discord account.
Each user after registration can mint **one** avatar.

## Avatars

Avatars are owned by AccountIdentifier (EXT standard 😡).
Usally users will mint one avatar and own it in their main account BUT that is far from guaranteed !
Avatars are what received airdrops as they are used to stake stars and points (in the MVP of the gameplay).

## Scenario

Expected behaviour : user log in and is authenticated through his Principal.

Principal -> Hub canister -> Log user profile.
Principal -> Avatar canister -> AccountIdentifier (default to subaccount 0) -> Log user avatar.

### Potential issues

- If the user moves his avatar to a different subaccount of the same principal, it will not be detected.
- If the user has multiple avatars, he will only be able to load one at the time being (this is expected as the gameplay prevents having multiple avatars).

## Current userflow to join.

Users go trough a registration process where they have to submit their personal informations, then they pay and then they can mint their avatar.

## Expected userflow.

Users land on the webpage and are (directly?) shown the avatar minter, once they are done creating their avatar, they are asked to log in and mint.

- Members and have already minted. A message indicate that they cannot mint a new avatar (doesn't prevent them for using an other wallet but at least warn them that this is not part of the gameplay).

- Members and haven't minted. They can continue and send the mint request.

- Not a member. Automatically create an invoice for charging 1ICP and send the details of the payment back to the client.
  Once they are done processing the payment on the frontend using their wallet they send the mint request (which will indeed check that the payment has been processed before minting). It also creates a new user profile with empty section (twitter/discord) that they can fill in later.

## Future iteration of ICP Squad

- Move away from the EXT standard and uses a standard that uses Principal as owner for NFT (type DIP721).
- Hub/Avatar should be move into one canister.
- Userflow : Land on the page -> Avatar minter -> Pay and mint -> Create a NFT (associated with their principal) and a user profile (associated with their principal) !
