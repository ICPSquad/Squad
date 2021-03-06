import { accessoriesActor } from "../actor";
import { fetchIdentity } from "../keys";
import type { Template } from "../declarations/accessories/accessories.did.d";
import { createReadStream, readFileSync } from "fs";
import csvParser from "csv-parser";

const canisters =
  process.env.NODE_ENV === "production"
    ? JSON.parse(readFileSync(`${__dirname}/../../canister_ids.json`).toString())
    : JSON.parse(readFileSync(`${__dirname}/../../.dfx/local/canister_ids.json`).toString());

const accessoriesID = process.env.NODE_ENV === "production" ? canisters.accessories.ic : canisters.accessories.local;
const network = process.env.NODE_ENV === "production" ? "ic" : "local";

console.log("Deploying all cards to the accessory canister : " + accessoriesID + " on network : " + network);

const results = [];
function createAccessory(name: string, slot: string, recipe: string): Template {
  const separator = `<text x="190.763px" y="439.84px" style="font-family: 'Futura-Medium', 'Futura', sans-serif; font-weight: 500; font-size: 50px; fill: white" id="wear_value"></text>`;
  let small_name = name.toLowerCase();
  let file = readFileSync(`${__dirname}/../../assets/cards/accessories/${slot}/${small_name}/${small_name}-minified.svg`);
  let content = file.toString();
  if (!content.includes(separator)) {
    throw new Error(`${name} is not in the correct format. Please check the svg file.`);
  }
  let array = content.split(separator);
  if (array.length != 2) {
    throw new Error("Something went wrong...array size should be two. Please check the svg file.");
  }
  let recipe_array = createRecipe(recipe);
  let accessory: Template = {
    Accessory: {
      before_wear: array[0],
      after_wear: array[1],
      recipe: recipe_array,
    },
  };
  return accessory;
}

function createMaterial(name: string): Template {
  let small_name = name.toLowerCase();
  let file = readFileSync(`${__dirname}/../../assets/cards/materials/${small_name}.svg`);
  let array = [...file];
  return {
    Material: array,
  };
}

function createRecipe(recipe: string): Array<string> {
  let array = recipe.split("/");
  return array;
}

async function upload() {
  let identity = fetchIdentity("admin");
  let actor = accessoriesActor(identity);
  let size = results.length;
  for (let i = 0; i < size; i++) {
    let element = results[i];
    if (element.category === "Material") {
      let template = createMaterial(element.name);
      let result = await actor.add_template(element.name, template);
      if (result.hasOwnProperty("ok")) {
        console.log("Uploaded card for : " + element.name + ".");
      } else {
        console.log("Failed to upload card for : " + element.name + ".");
      }
    } else if (element.category === "Accessory") {
      let template = createAccessory(element.name, element.slot, element.recipe);
      let result = await actor.add_template(element.name, template);
      if (result.hasOwnProperty("ok")) {
        console.log("Uploaded card for : " + element.name + ".");
      } else {
        console.log("Failed to upload card for : " + element.name + ".");
      }
    }
  }
}

createReadStream(`${__dirname}/../../assets/cards/manifest-cards.csv`)
  .pipe(csvParser())
  .on("data", (data) => {
    results.push(data);
  })
  .on("end", () => {
    upload();
  });
