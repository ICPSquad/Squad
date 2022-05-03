import type { Invoice__1 as Invoice } from "@canisters/invoice/invoice.did.d";
import type { Wallet } from "@src/types/wallet";
import { StoicIdentity } from "ic-stoic-identity";
import { ledgerActor } from "@src/api/actor";
import type { Identity } from "@dfinity/agent";
import type { TransferArgs, TransferResult } from "@canisters/ledger/ledger.did.d";

export async function payInvoice(invoice: Invoice, wallet: Wallet): Promise<{ height: number }> {
  const { paid, expiration } = invoice;
  if (paid) {
    throw new Error("This invoice has already been paid");
  }
  if (expiration < Date.now() * 100_000) {
    throw new Error("This invoice has already been paid");
  }
  switch (wallet) {
    case "plug":
      pay_plug(invoice.destination, invoice.memo, invoice.amount);
    case "stoic":
      pay_stoic(invoice.address, invoice.memo, invoice.amount);
  }
}

async function pay_plug(
  address: string,
  memo: bigint,
  amount: number
): Promise<{
  height: number;
}> {
  const resultTransfer = await window.ic.plug.requestTransfer({
    to: address,
    amount: amount,
    memo: String(memo),
  });
  if (resultTransfer) {
    return {
      height: resultTransfer.height,
    };
  } else {
    throw new Error("Transfer failed");
  }
}

async function pay_stoic(address: string, memo: bigint, amount: number): Promise<{ height: number }> {
  let identity: Identity;
  try {
    StoicIdentity.load().then(async (object) => {
      if (object) {
        identity = object;
      } else {
        identity = await StoicIdentity.create();
      }
    });
  } catch (e) {
    throw new Error("Failed to load identity using Stoic");
  }

  const ledger = ledgerActor(identity);
  const agrs: TransferArgs = {
    to: Array.from(new Uint8Array(Buffer.from(address, "hex"))),
    amount: { e8s: BigInt(amount) },
    fee: { e8s: BigInt(10_000) },
    memo: BigInt(memo),
    from_subaccount: [],
    created_at_time: [],
  };
  try {
    const result: TransferResult = await ledger.transfer(agrs);
    if (result.hasOwnProperty("Ok")) {
      return {
        //@ts-ignore
        height: result.Ok.toNumber(),
      };
    } else {
      throw new Error("Transfer failed");
    }
  } catch {
    throw new Error("Transfer failed");
  }
}
