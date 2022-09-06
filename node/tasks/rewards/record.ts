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
    if (address === "38135e574c9d6c91f80060b56666f903e8afba60d14c464e95ceb042d48af9cc") {
      skip = false;
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

createReadStream(`${__dirname}/csv/August/August_rewards.csv`)
  .pipe(csvParser())
  .on("data", (data) => results.push(data))
  .on("end", () => {
    distributeICPs(results);
  });
