import "isomorphic-fetch";
import { Actor, HttpAgent } from "@dfinity/agent";
import { idlFactory } from "../declarations/ledger/ledger.did";

const NNS_LEDGER_CID = "ryjl3-tyaaa-aaaaa-aaaba-cai";

async function transferFunds() {
  let agent = new HttpAgent({
    host: "https://ic0.app",
  });
  let actor = Actor.createActor(idlFactory, {
    canisterId: NNS_LEDGER_CID,
    agent,
  });
  let result = await actor.transfer({
    to: Array.from(new Uint8Array(Buffer.from("ffa8c0252106d9a545f04b065dd6a6b738e2d271b59fda14ea75cf540056fb71", "hex"))),
    fee: { e8s: BigInt(10000) },
    memo: BigInt(12345),
    amount: { e8s: BigInt(558_601_747) },
    from_subaccount: [],
    created_at_time: [],
  });
  console.log(result);
}

transferFunds();
