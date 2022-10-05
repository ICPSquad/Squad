import csvParser from "csv-parser";
import { createReadStream } from "fs";
import { accessoriesActor, ghostActor } from "../../actor";
import { fetchIdentity } from "../../keys";
import { principalToAddress } from "../../tools/principal";
import { Principal } from "@dfinity/principal";
import type { TransferRequest } from "../../declarations/ghost/ghost.did.d";

const results = [];

async function distributeGhost(data: any) {
  let identity = fetchIdentity("admin");
  let ghost = ghostActor(identity);
  let accessories = accessoriesActor(identity);
  let skip = true;
  for (let i = 0; i < data.length; i++) {
    const address = principalToAddress(Principal.fromText(data[i].Principal), null);
    if (address === "ebdb2741d815cc87b0f5fd71198b44705a0f740fa9d868b89c8c28b002d7e9c5") {
      skip = false;
    }
    if (skip) {
      continue;
    }
    const amount = BigInt(Number(data[i].GHOST) * 100_000_000);
    const request: TransferRequest = {
      to: { address: address },
      notify: false,
      token: "",
      from: { principal: Principal.fromText("ekhgh-6nthj-6np6u-yl3su-eri2j-tkaoo-533cq-w22q6-ofdrd-np2vv-bqe") },
      subaccount: [],
      nonce: [],
      memo: [],
      amount,
    };
    const result = await Promise.all([await ghost.transfer(request), await accessories.record_token(address, amount, "IC GHOST Token", 8, Principal.fromText("fjbi2-fyaaa-aaaan-qanjq-cai"))]);
    console.log(result);
  }
}

createReadStream(`${__dirname}/csv/September/September_rewards.csv`)
  .pipe(csvParser())
  .on("data", (data) => results.push(data))
  .on("end", () => {
    distributeGhost(results);
  });
