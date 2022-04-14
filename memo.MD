# Users & Avatar

## Users

Users are authenticated through their Principal; ie the Principal of the wallet they use to log in (Plug or Stoic). We moved away from Internet Identity as it doesn't allow cross-app tracking which is necessayr for the gameplay.

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

## Future iteration of ICP Squad

- Move away from the EXT standard and uses a standard that uses Principal as owner for NFT (type DIP721).
- Hub/Avatar should be moved into one canister.
