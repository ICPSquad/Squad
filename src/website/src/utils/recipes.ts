import type { Inventory, ItemInventory } from "@canisters/accessories/accessories.did.d";
import type { Recipe } from "@canisters/accessories/accessories.did.d";
const recipes = {
  "shinobi-hat": ["cloth", "cloth", "cloth", "cloth", "cloth", "cloth", "cloth", "cloth", "cloth", "cloth", "cloth", "cloth", "wood"],
  "assassin-hood": ["cloth", "cloth", "cloth", "cloth", "cloth", "cloth", "cloth", "cloth", "cloth", "cloth", "wood", "wood", "wood", "glass", "metal", "metal", "metal"],
  "astro-helmet": [
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "wood",
    "wood",
    "wood",
    "wood",
    "wood",
    "glass",
    "glass",
    "glass",
    "metal",
    "metal",
    "metal",
    "circuit",
    "circuit",
    "circuit",
    "dfinity-stone",
  ],
  helicap: ["cloth", "cloth", "cloth", "cloth", "wood", "wood", "wood", "wood", "circuit", "metal"],
  "magic-hood": [
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "wood",
    "wood",
    "wood",
    "wood",
    "wood",
    "wood",
    "wood",
    "wood",
    "wood",
    "wood",
    "glass",
    "glass",
    "glass",
    "glass",
    "metal",
    "metal",
    "metal",
    "metal",
    "metal",
    "circuit",
    "dfinity-stone",
  ],
  "marshall-hat": ["cloth", "cloth", "cloth", "cloth", "cloth", "cloth", "wood", "wood", "wood", "wood", "wood", "wood", "glass", "glass", "glass", "metal", "metal", "metal", "circuit"],
  "mortaboard-hat": [],
  "ninja-headband": ["cloth", "cloth", "cloth", "cloth", "cloth", "cloth", "cloth", "cloth", "cloth", "cloth", "wood", "wood", "wood", "wood", "wood", "wood", "metal", "circuit", "circuit"],
  "boring-mask": ["cloth"],
  "juggalo-facemask": ["cloth", "cloth", "cloth", "cloth", "wood", "wood", "wood", "wood", "wood", "wood", "wood", "wood", "glass", "metal", "metal", "metal", "metal"],
  "oni-face-mask": ["wood", "wood", "wood", "wood", "wood", "wood", "wood", "wood", "glass", "glass", "glass", "glass", "metal", "metal", "metal", "metal", "circuit"],
  facemask: ["cloth", "cloth", "wood", "wood", "wood", "wood", "wood", "wood", "wood", "wood", "wood", "glass", "glass", "metal", "metal", "metal", "metal", "metal", "circuit"],
  "gas-mask": ["cloth", "cloth", "cloth", "wood", "wood", "wood", "wood", "wood", "wood", "glass", "glass", "glass", "glass", "glass", "metal", "metal", "metal", "metal", "circuit", "circuit"],
  "kitsune-mask": [
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "wood",
    "wood",
    "wood",
    "wood",
    "wood",
    "glass",
    "glass",
    "glass",
    "metal",
    "metal",
    "metal",
    "circuit",
    "circuit",
    "circuit",
  ],
  "evil-mask": [
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "wood",
    "wood",
    "wood",
    "wood",
    "wood",
    "glass",
    "glass",
    "glass",
    "metal",
    "metal",
    "metal",
    "circuit",
    "circuit",
    "dfinity-stone",
  ],
  "punk-mask": [],
  "cronic-eyepatch": [],
  "dfinity-eyemask": [
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "wood",
    "wood",
    "wood",
    "wood",
    "wood",
    "glass",
    "glass",
    "glass",
    "glass",
    "metal",
    "metal",
    "metal",
    "circuit",
    "circuit",
    "dfinity-stone",
  ],
  "lab-glasses": ["cloth", "cloth", "wood", "glass", "glass", "glass"],
  monocle: ["glass", "metal", "metal", "metal"],
  "punk-glasses": [],
  sunglasses: ["cloth", "cloth", "cloth", "cloth", "glass", "glass", "glass", "metal", "circuit"],
  "assassin-cap": ["cloth", "cloth", "wood", "wood", "wood", "wood", "wood", "wood", "glass", "metal", "metal", "metal", "metal", "metal", "metal"],
  "astro-suit": [
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "glass",
    "glass",
    "glass",
    "glass",
    "glass",
    "metal",
    "metal",
    "metal",
    "metal",
    "metal",
    "circuit",
    "circuit",
    "circuit",
    "circuit",
    "circuit",
    "dfinity-stone",
  ],
  "bootcamp-soldier": [],
  "cronic-tshirt": [],
  "devil-jacket": [
    "cloth",
    "cloth",
    "wood",
    "wood",
    "wood",
    "wood",
    "wood",
    "wood",
    "glass",
    "glass",
    "glass",
    "glass",
    "glass",
    "glass",
    "metal",
    "metal",
    "metal",
    "metal",
    "metal",
    "metal",
    "circuit",
    "circuit",
  ],
  "helicap-tshirt": ["cloth", "cloth", "cloth", "cloth", "cloth", "cloth", "cloth", "cloth", "cloth", "cloth", "cloth", "cloth"],
  "lab-coat": ["cloth", "cloth", "cloth", "cloth", "wood", "wood", "wood", "wood", "wood", "wood", "wood", "wood", "glass", "glass", "metal", "circuit", "circuit"],
  "magic-cap": [
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "wood",
    "wood",
    "wood",
    "wood",
    "wood",
    "wood",
    "wood",
    "wood",
    "wood",
    "wood",
    "glass",
    "glass",
    "glass",
    "glass",
    "glass",
    "metal",
    "metal",
    "metal",
    "metal",
    "circuit",
    "circuit",
    "circuit",
    "dfinity-stone",
  ],
  "shinobi-suit": ["cloth", "cloth", "cloth", "cloth", "cloth", "cloth", "cloth", "cloth", "cloth", "cloth", "wood", "glass", "glass", "glass", "metal", "metal", "metal", "circuit", "circuit"],
  "street-jacket": ["cloth", "cloth", "cloth", "cloth", "cloth", "cloth", "wood", "wood", "wood", "wood", "wood", "wood", "wood", "wood", "wood", "wood"],
  "super-suit": ["todo"],
  "yakuza-suit": ["cloth", "cloth", "cloth", "cloth", "wood", "wood", "wood", "wood", "glass", "glass", "metal", "metal", "metal", "circuit", "circuit"],
  "cronic-hypnose": ["todo"],
  "cronic-wallpaper": ["todo"],
  snowfall: [
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "wood",
    "wood",
    "wood",
    "wood",
    "wood",
    "wood",
    "wood",
    "wood",
    "wood",
    "wood",
    "wood",
    "wood",
    "wood",
    "wood",
    "wood",
    "wood",
    "wood",
    "glass",
    "glass",
    "glass",
    "glass",
    "glass",
    "metal",
    "metal",
    "metal",
    "metal",
    "circuit",
    "circuit",
    "circuit",
    "dfinity-stone",
    "dfinity-stone",
  ],
  sunrise: [
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "cloth",
    "wood",
    "wood",
    "wood",
    "wood",
    "wood",
    "wood",
    "wood",
    "wood",
    "wood",
    "wood",
    "wood",
    "wood",
    "wood",
    "wood",
    "wood",
    "wood",
    "wood",
    "glass",
    "glass",
    "glass",
    "glass",
    "glass",
    "metal",
    "metal",
    "metal",
    "metal",
    "circuit",
    "circuit",
    "circuit",
    "dfinity-stone",
    "dfinity-stone",
  ],
};

const description = {
  "shinobi-hat": "A hat made of cloth and wood. It is worn by the squad ninja.",
  helicap: "",
  "assassin-hood": "The perfect hood to hide your identity. KYC not required.",
  "marshall-hat": "A hat usually worn by moderators. Protect againt scammers.",
  "ninja-headband": "This headband is offered to all ninja after they've been trough their neuron locking ceremony.",
  "magic-hood": "This hood is used by the magicians of modern times.",
  "kitsune-mask": `This mask is proudly worn by the warriors of the famous 8Years-gang.\n\nDoesn't protect against liquidation.`,
  "astro-helmet": `The helmet for astronaut. Made of expensive and solid materials.\n\nCan bring you to the moon and beyond.`,
  "mortaboard-hat": `Airdropped to all students who graduated from the 1st edition of the Motoko Bootcamp.\n\nCannot be minted again.`,
  "boring-mask": "A mask made of cloth. It's not very protective but at least you can use it to hide your face whenever you want.",
  "juggalo-facemask": "The facial paint you need to join the juggalos. Not the ICP you think.",
  "oni-face-mask": "Confers protection and benediction from the spirits.",
  facemask: "Not very protective but at least this one has nice color.",
  "gas-mask": "This mask is the most protective you can find. Protect against chemicals, virus and dirty odors.",
  "evil-mask": "Only for the most evil of the squad.",
  "lab-glasses": "The pair of glasses you need when testing new recipes.",
  monocle: "When you want to look rich but you're not.",
  sunglasses: "Any similarity with a famous movie is fortuitous.",
  "dfinity-eyemask": "Who said you can't see the future?",
  "punk-glasses": "Todo",
  "cronic-eyepatch": "Soon.",
  "helicap-tshirt": "",
  "assassin-cap": "The perfect cap to complete your assassin outfit.",
  "lab-coat": "This coat increases your Motoko coding abilities.",
  "shinobi-suit": "An impressive suit to hide your face. Perfect to complete your ninja outfit.",
  "yakuza-suit": "",
  "super-suit": "Great powers comes with great responsibilities.",
  "devil-jacket": "An impressive jacket made of cloth and metals. ",
  "street-jacket": "The perfect jacket to roam the streets.",
  "magic-cap": "A cap made of a multitude of high quality materials. Perfect to complete your magic outfit.",
  "astro-suit": "A must have to enter the ICP-rocket. Doesn't protect against crash landing.",
  "cronic-tshirt": "Soon.",
  "bootcamp-soldier": `Airdropped to all students who graduated from the 1st edition of the Motoko Bootcamp.\n\nCannot be minted again.`,
  snowfall: "Put your jacket on. It's cold.",
  sunrise: "After the darkness, the sun always rises.",
  "cronic-hypnose": "A session of cronic hypnose can increase your odds of stopping cigarettes and reduce your stress.",
  "cronic-wallpaper": "The perfect wallpaper for the room of your kids.",
};

export function nameToRecipe(name: string): string[] {
  return recipes[name] ? recipes[name] : [""];
}

export function nameToDescription(name: string): string {
  return description[name] ? description[name] : "";
}

export type RecipeAnswer = { ok: string[] } | { err: string[] };

/* Before minting an accessory we need to verify that the user own the required materials, and if so keep track of the list of token identifier for those materials.
   'ok' : Returns a list of token identifier that correspond to the materials required to mint the accessory.
   'err' : Returns a list of missing materials to complete the recipe.  
 */
export function createMintTokensFromInventoryAndRecipe(recipe: Recipe, inventory: Inventory): RecipeAnswer {
  let tmp_copy_inventory = { ...inventory };
  console.log("Inventory", tmp_copy_inventory);
  let missing_materials: string[] = [];
  let mint_tokens: string[] = [];
  for (let material of recipe) {
    console.log("Loop");
    let material_token_id = nameToTokenIdentifier(material, tmp_copy_inventory);
    console.log("Material token id", material_token_id);
    if (!material_token_id) {
      console.log("We have a *** missing material ***", material);
      missing_materials.push(material);
    } else {
      console.log("We have a *** mint token ***", material_token_id);
      mint_tokens.push(material_token_id);
      filterInventory(material_token_id, tmp_copy_inventory);
    }
  }
  console.log("Missing materials", missing_materials);
  if (missing_materials.length > 0) {
    return { err: missing_materials };
  } else {
    return { ok: mint_tokens };
  }
}

/* Returns the optional first TokenIdentifier that corresponds to the name of the item */
function nameToTokenIdentifier(name: string, inventory: Inventory): string | null {
  let keys = Object.keys(inventory);
  keys.forEach((key) => {
    if (itemToName(inventory[key]) === name) {
      console.log("Found", key);
      return itemToTokenIdentifier(inventory[key]);
    }
  });
  return null;
}

function itemToName(item: ItemInventory): string {
  console.log("Item", item);
  //@ts-ignore
  if (item.Material) {
    //@ts-ignore
    return item.Material.name.toLowerCase();
  }
  //@ts-ignore
  if (item.Accessory) {
    //@ts-ignore
    return item.Accessory.name.toLowerCase();
  }
  throw new Error("itemToName: item is not an accessory nor a material");
}

function itemToTokenIdentifier(item: ItemInventory): string {
  console.log("ItemToTokenId", item);
  //@ts-ignore
  if (item.Material) {
    //@ts-ignore
    console.log("We are returning the name of the material", item.Material.name);
    //@ts-ignore
    return item.Material.tokenIdentifier;
  }
  //@ts-ignore
  if (item.Accessory) {
    //@ts-ignore
    return item.Accessory.tokenIdentifier;
  }
  throw new Error("itemToTokenIdentifier: item is not an accessory or material");
}

function filterInventory(token_identifier: string, inventory: Inventory): Inventory {
  return inventory.filter((item) => itemToTokenIdentifier(item) !== token_identifier);
}