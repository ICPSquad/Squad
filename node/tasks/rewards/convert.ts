import csvParser from "csv-parser";
import { Principal } from "@dfinity/principal";
import { fetchIdentity } from "../../keys";
import { accessoriesActor } from "../../actor";
import { createReadStream, readFileSync } from "fs";
import { principalToAddress } from "../../tools/principal";
import type { AccountIdentifier, Airdrop } from "@canisters/accessories/accessories.did.d";
const results = [];
const output: [AccountIdentifier, Airdrop][] = [];

const canisters =
  process.env.NODE_ENV === "production"
    ? JSON.parse(readFileSync(`${__dirname}/../../../canister_ids.json`).toString())
    : JSON.parse(readFileSync(`${__dirname}/../../../.dfx/local/canister_ids.json`).toString());

const accessoriesID = process.env.NODE_ENV === "production" ? canisters.accessories.ic : canisters.accessories.local;
const network = process.env.NODE_ENV === "production" ? "ic" : "local";

console.log("Airdrop in progress using  : " + accessoriesID + " on network : " + network);

createReadStream(`${__dirname}/csv/July_rewards.csv`)
  .pipe(csvParser())
  .on("data", (data) => results.push(data))
  .on("end", () => {
    var nb_cloth_total = 0;
    var nb_wood_total = 0;
    var nb_glass_total = 0;
    var nb_metal_total = 0;
    var nb_circuit_total = 0;
    var nb_stone_total = 0;
    results.forEach((result) => {
      nb_cloth_total += Number(result.Cloth);
      nb_wood_total += Number(result.Wood);
      nb_glass_total += Number(result.Glass);
      nb_metal_total += Number(result.Metal);
      nb_circuit_total += Number(result.Circuit);
      nb_stone_total += Number(result.Dfinity);
      const account = principalToAddress(Principal.fromText(result.Principal));
      const airdrop = createAirdrop(result);
      output.push([account, airdrop]);
    });
    // distribute();
    console.log("Numbers of cloth : " + nb_cloth_total);
    console.log("Numbers of wood : " + nb_wood_total);
    console.log("Numbers of glass : " + nb_glass_total);
    console.log("Numbers of metal : " + nb_metal_total);
    console.log("Numbers of circuit : " + nb_circuit_total);
    console.log("Numbers of stone : " + nb_stone_total);
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
  console.log("");
  return output;
}

async function distribute() {
  let identity = fetchIdentity("admin");
  console.log("My principal is : " + identity.getPrincipal().toString());
  let actor = accessoriesActor(identity);
  let result = await actor.airdrop_rewards(output);
  console.log("Airdrop result : " + result);
  console.log("Rewards have been distributed.");
}
