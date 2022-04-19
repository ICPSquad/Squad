import { SendArgs } from "./ledger";
import { FEE } from "./const";
import { SubAccount } from "declarations/hub/hub.did.d";
import { principalToAccountIdentifier } from "./accountid";

export const getRandomSubaccount = (): number[] => {
  var bs: number[] = [];
  for (var i = 0; i < 32; i++) {
    bs.push(Math.floor(Math.random() * 256));
  }
  return bs;
};

export async function pay_plug(
  subaccount: SubAccount,
  memo: bigint,
  amount: number,
  canister_id: string
): Promise<{
  height: number;
}> {
  let address_to_pay = principalToAccountIdentifier(canister_id, subaccount);

  //@ts-ignore
  const resultTransfer = await window.ic.plug.requestTransfer({
    to: address_to_pay,
    amount: amount,
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

export async function pay_stoic(ledgerActor: any, subaccount: SubAccount, memo: bigint, amount: number, canister_id: string): Promise<{ height: number }> {
  let address_to_pay = principalToAccountIdentifier(canister_id, subaccount);
  let send_args: SendArgs = {
    to: address_to_pay,
    fee: FEE,
    memo,
    amount: { e8s: BigInt(amount) },
    from_subaccount: [],
    created_at_time: [{ timestamp_nanos: BigInt(Date.now() * 1000000) }],
  };
  let height = await ledgerActor.send_dfx(send_args);
  return { height: Number(height) };
}
