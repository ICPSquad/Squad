import type { Identity } from "@dfinity/agent";
import { ledgerActor } from "../actor";

export async function transferICPs(identity: Identity, amount: bigint, to: string) {
  let ledger = ledgerActor(identity);
  let result = await ledger.transfer({
    to: Array.from(new Uint8Array(Buffer.from(to, "hex"))),
    fee: { e8s: BigInt(10000) },
    memo: BigInt(12345),
    amount: { e8s: amount },
    from_subaccount: [],
    created_at_time: [],
  });
  console.log(result);
}
