import { principalToAddress } from "../tools/principal";
import csvParser from "csv-parser";
import { Principal } from "@dfinity/principal";
import { createReadStream, writeFileSync, existsSync, mkdirSync, appendFileSync } from "fs";

const results = [];

const PATH = `${__dirname}/address.txt`;
const DIR = `${__dirname}`;

function createList(data: any) {
  if (!existsSync(PATH)) mkdirSync(DIR, { recursive: true });
  if (!existsSync(PATH)) writeFileSync(PATH, "", { flag: "wx" });

  writeFileSync(PATH, "Rank,Address");
  appendFileSync(PATH, "\n");
  let i = 0;
  while (i < 50) {
    const address = principalToAddress(Principal.fromText(data[i].Principal), null);
    appendFileSync(PATH, `${i + 1},${address}`);
    appendFileSync(PATH, "\n");
    i++;
  }
}

createReadStream(`${__dirname}/rewards/csv/September/September_rewards.csv`)
  .pipe(csvParser())
  .on("data", (data) => results.push(data))
  .on("end", () => {
    createList(results);
  });
