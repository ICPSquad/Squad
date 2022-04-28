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
- [x] Integrates [**CanisterGeek**](https://cusyh-iyaaa-aaaah-qcpba-cai.raw.ic0.app/) for **monitoring** and **logs** system.
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
