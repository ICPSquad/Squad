import { Actor, Agent } from "@dfinity/agent";
import ledgerIDL from "../types/Ledger/ledger.did";
export { ICPTs, Memo, SendArgs } from "../types/Ledger/ledger.did.d";
export const LEDGER_CANISTER_ID = "ryjl3-tyaaa-aaaaa-aaaba-cai";

function createLedgerCanister(agent: Agent) {
  return Actor.createActor(ledgerIDL, {
    agent,
    canisterId: LEDGER_CANISTER_ID,
  });
}

export { createLedgerCanister };
