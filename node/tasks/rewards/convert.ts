import csvParser from "csv-parser";
import { Principal } from "@dfinity/principal";
import { createReadStream, readFileSync } from "fs";
import { principalToAddress } from "../../tools/principal";
import type { AccountIdentifier, Airdrop } from "@canisters/accessories/accessories.did.d";
const results = [];
const output: [AccountIdentifier, Airdrop][] = [];

createReadStream(`${__dirname}/csv/July_rewards.csv`)
  .pipe(csvParser())
  .on("data", (data) => results.push(data))
  .on("end", () => {
    results.forEach((result) => {
      const account = principalToAddress(Principal.fromText(result.Principal));
      const airdrop = createAirdrop(result);
      output.push([account, airdrop]);
    });
    console.log(output);
  });

function createAirdrop(data): Airdrop {
  const nb_cloth = Number(data.Cloth);
  const nb_wood = Number(data.Wood);
  const nb_glass = Number(data.Glass);
  const nb_metal = Number(data.Metal);
  const nb_circuit = Number(data.Circuit);
  const nb_stone = Number(data.Dfinity);
  const output: Airdrop = [];
  for (let i = 0; i < nb_cloth; i++) {
    output.push("Cloth");
  }
  for (let i = 0; i < nb_wood; i++) {
    output.push("Wood");
  }
  for (let i = 0; i < nb_glass; i++) {
    output.push("Glass");
  }
  for (let i = 0; i < nb_metal; i++) {
    output.push("Metal");
  }
  for (let i = 0; i < nb_circuit; i++) {
    output.push("Circuit");
  }
  for (let i = 0; i < nb_stone; i++) {
    output.push("Dfinity-stone");
  }
  return output;
}
