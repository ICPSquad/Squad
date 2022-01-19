import { HttpAgent } from "@dfinity/agent";
import { Principal } from "@dfinity/principal";
import { createLedgerCanister, SendArgs } from "./ledger";
import { MEMO, FEE, AMOUNT, RECEIVER } from "./const";
import { SubAccount } from "declarations/hub/hub.did.d";
import { principalToAccountIdentifier } from "./accountid";

const getRandomSubaccount = (): number[] => {
  var bs: number[] = [];
  for (var i = 0; i < 32; i++) {
    bs.push(Math.floor(Math.random() * 256));
  }
  return bs;
};

export async function pay_plug(): Promise<{
  subaccount: SubAccount;
  height: number;
}> {
  let subaccount_array = getRandomSubaccount();
  let address_to_pay = principalToAccountIdentifier(
    "p4y2d-yyaaa-aaaaj-qaixa-cai",
    subaccount_array
  );
  console.log("Address to pay: ", address_to_pay);

  //@ts-ignore
  const resultTransfer = await window.ic.plug.requestTransfer({
    to: address_to_pay,
    amount: 100000000,
  });

  return { subaccount: subaccount_array, height: resultTransfer.height };
}

export async function pay_stoic(
  identity: any
): Promise<{ subaccount: SubAccount; height: number }> {
  let subaccount_array = getRandomSubaccount();
  let address_to_pay = principalToAccountIdentifier(
    "p4y2d-yyaaa-aaaaj-qaixa-cai",
    subaccount_array
  );

  let http_agent = new HttpAgent({ identity });
  let ledger_actor = createLedgerCanister(http_agent);

  let send_args: SendArgs = {
    to: address_to_pay,
    fee: FEE,
    memo: MEMO,
    amount: AMOUNT,
    from_subaccount: [],
    created_at_time: [{ timestamp_nanos: BigInt(Date.now() * 1000000) }],
  };
  let height = await ledger_actor.send_dfx(send_args);
  return { subaccount: subaccount_array, height: Number(height) };
}
