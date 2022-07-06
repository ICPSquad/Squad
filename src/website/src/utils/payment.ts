import type { AccountIdentifier, Invoice__1 as Invoice } from "@canisters/invoice/invoice.did.d";
import type { Wallet } from "@src/types/wallet";
import { StoicIdentity } from "ic-stoic-identity";
import { ledgerActor } from "@src/api/actor";
import type { _SERVICE as Ledger } from "@canisters/ledger/ledger.did.d";
import type { TransferArgs, TransferResult } from "@canisters/ledger/ledger.did.d";
import type { ActorSubclass } from "@dfinity/agent";

export async function payInvoice(invoice: Invoice, wallet: Wallet): Promise<{ height: number }> {
  const { paid, expiration } = invoice;
  if (paid) {
    throw new Error("This invoice has already been paid");
  }
  if (expiration < Date.now() * 100_000) {
    throw new Error("This invoice has already been paid");
  }
  if (wallet === "plug") {
    //@ts-ignore
    return await pay_plug(invoice.destination.text, Number(invoice.amount));
  } else if (wallet === "stoic") {
    //@ts-ignore
    return await pay_stoic(invoice.destination.text, Number(invoice.amount));
  } else {
    throw new Error("Unknown wallet");
  }
}

async function pay_plug(
  address: string,
  amount: number
): Promise<{
  height: number;
}> {
  const resultTransfer = await window.ic.plug.requestTransfer({
    to: address,
    amount: amount,
    memo: "12345",
  });
  if (resultTransfer) {
    return {
      height: resultTransfer.height,
    };
  } else {
    throw new Error("Transfer failed");
  }
}

async function pay_stoic(address: string, amount: number): Promise<{ height: number }> {
  const agrs: TransferArgs = {
    to: Array.from(new Uint8Array(Buffer.from(address, "hex"))),
    amount: { e8s: BigInt(amount) },
    fee: { e8s: BigInt(10_000) },
    memo: BigInt(12345),
    from_subaccount: [],
    created_at_time: [],
  };
  let height: number;
  let identity = await StoicIdentity.load();
  if (identity !== false) {
    let ledger = ledgerActor(identity);
    const result: TransferResult = await ledger.transfer(agrs);
    if ("Ok" in result) {
      height = Number(result.Ok);
    }
  } else {
    identity = await StoicIdentity.connect();
    let ledger = ledgerActor(identity);
    const result: TransferResult = await ledger.transfer(agrs);
    if ("Ok" in result) {
      height = Number(result.Ok);
    }
  }
  return { height: height };
}
