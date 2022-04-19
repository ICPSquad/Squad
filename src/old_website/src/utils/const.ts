// Canister id
export const LEDGER_CANISTER_ID = "ryjjl3-tyaaa-aaaaa-aaaba-cai";
export const HUB_CANISTER_ID = "p4y2d-yyaaa-aaaaj-qaixa-cai";
export const AVATAR_CANISTER_ID = "jmuqr-yqaaa-aaaaj-qaicq-cai";
export const ACCESSORIES_CANISTER_ID = "po6n2-uiaaa-aaaaj-qaiua-cai";

// Internet computer host address
export const HOST = "https://mainnet.dfinity.network";

// Payment
import { ICPTs, Memo } from "interfaces/ledger/ledger.did.d";
export { ICPTs, Memo } from "interfaces/ledger/ledger.did.d";

export const FEE: ICPTs = { e8s: BigInt(10000) };
export const AMOUNT: ICPTs = { e8s: BigInt(100000000) }; //1 ICP
export const AMOUNT_ACCESSORY_MINTING: ICPTs = { e8s: BigInt(10000) }; //TODO: change to 0.1
export const MEMO: Memo = BigInt(0);
