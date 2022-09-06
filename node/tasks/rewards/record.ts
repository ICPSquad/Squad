import csvParser from "csv-parser";
import { createReadStream } from "fs";
import { accessoriesActor, ledgerActor } from "../../actor";
import { fetchIdentity } from "../../keys";
import { principalToAddress } from "../../tools/principal";
import { transferICPs } from "../../utils/ledger";
import { Principal } from "@dfinity/principal";

const results = [];

async function distributeICPs(data: any) {
  let identity = fetchIdentity("admin");
  let accessories = accessoriesActor(identity);
  for (let i = 0; i < data.length; i++) {
    const address = principalToAddress(Principal.fromText(data[i].Principal), null);
    const amount = Number(data[i].ICPs);
    const resultTransfer = await transferICPs(identity, amount, address);
    const resultLog = await accessories.record_icps(address, BigInt(amount * 10 ** 8));
    console.log("Transfer: ", resultTransfer);
    console.log("Log: ", resultLog);
  }
}

createReadStream(`${__dirname}/csv/August/August_rewards.csv`)
  .pipe(csvParser())
  .on("data", (data) => results.push(data))
  .on("end", () => {
    distributeICPs(results);
  });
