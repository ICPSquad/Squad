import csvParser from "csv-parser";
import { createReadStream } from "fs";
import { accessoriesActor } from "../../actor";
import { fetchIdentity } from "../../keys";
import { principalToAddress } from "../../tools/principal";
import { transferICPs } from "../../utils/ledger";
import { Principal } from "@dfinity/principal";

const results = [];

async function distributeICPs(data: any) {
  let identity = fetchIdentity("admin");
  let accessories = accessoriesActor(identity);
  let skip = true;
  for (let i = 0; i < data.length; i++) {
    const address = principalToAddress(Principal.fromText(data[i].Principal), null);
    const amount = BigInt(Number(data[i].ICPs * 1000) + "00000");
    if (address === "8ce3fc01834f0d0850e3bda320cd6988e2553bfaeba2da756e12f73ee3ef65e8") {
      skip = false;
    }
    if (address === "1b07d6d3410a112aa78be3d2279255783e2018b7dd75cdf1c9d834067a9ee214") {
      skip = true;
    }
    if (Number(amount) == 0 || skip) {
      continue;
    } else {
      const resultTransfer = await transferICPs(identity, amount, address);
      const resultLog = await accessories.record_icps(address, amount);
      console.log("Transfer: ", resultTransfer);
      console.log("Log: ", resultLog);
    }
  }
}

createReadStream(`${__dirname}/csv/September/September_rewards.csv`)
  .pipe(csvParser())
  .on("data", (data) => results.push(data))
  .on("end", () => {
    distributeICPs(results);
  });
