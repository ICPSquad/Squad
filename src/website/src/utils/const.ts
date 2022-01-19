// Canister id
export const LEDGER_CANISTER_ID = "ryjjl3-tyaaa-aaaaa-aaaba-cai";
export const HUB_CANISTER_ID = "p4y2d-yyaaa-aaaaj-qaixa-cai";

// Internet computer host address
export const HOST = "https://mainnet.dfinity.network";

// Payment
import { ICPTs, Memo } from "../types/Ledger/ledger.did.d";
export { ICPTs, Memo } from "../types/Ledger/ledger.did.d";

export const FEE: ICPTs = { e8s: BigInt(10000) };
export const AMOUNT: ICPTs = { e8s: BigInt(100000000) }; //1 ICP
export const MEMO: Memo = BigInt(0);
export const RECEIVER =
  "ffa8c0252106d9a545f04b065dd6a6b738e2d271b59fda14ea75cf540056fb71"; // Canister wallet address
