import { HttpAgent } from "@dfinity/agent";
import { createLedgerCanister, SendArgs } from "./ledger";
import { MEMO, FEE, AMOUNT } from "./const";
import { SubAccount } from "declarations/hub/hub.did.d";
import { principalToAccountIdentifier } from "./accountid";
import { stringify } from "postcss";

export const getRandomSubaccount = (): number[] => {
  var bs: number[] = [];
  for (var i = 0; i < 32; i++) {
    bs.push(Math.floor(Math.random() * 256));
  }
  return bs;
};

export async function pay_plug(
  subaccount: SubAccount,
  memo: bigint
): Promise<{
  height: number;
}> {
  let address_to_pay = principalToAccountIdentifier(
    "p4y2d-yyaaa-aaaaj-qaixa-cai",
    subaccount
  );

  //@ts-ignore
  const resultTransfer = await window.ic.plug.requestTransfer({
    to: address_to_pay,
    amount: 100000000,
    memo: String(memo),
  });
  if (resultTransfer) {
    return {
      height: resultTransfer.height,
    };
  } else {
    return {
      height: 0,
    };
  }
}

export async function pay_stoic(
  subaccount: SubAccount,
  memo: bigint,
  ledgerActor: any
): Promise<{ height: number }> {
  let address_to_pay = principalToAccountIdentifier(
    "p4y2d-yyaaa-aaaaj-qaixa-cai",
    subaccount
  );

  let send_args: SendArgs = {
    to: address_to_pay,
    fee: FEE,
    memo,
    amount: AMOUNT,
    from_subaccount: [],
    created_at_time: [{ timestamp_nanos: BigInt(Date.now() * 1000000) }],
  };
  let height = await ledgerActor.send_dfx(send_args);
  return { height: Number(height) };
}
