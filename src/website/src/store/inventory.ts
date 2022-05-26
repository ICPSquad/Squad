import { writable, get } from "svelte/store";
import { actors } from "./actor";
import type { InventoryStore } from "./types/inventory-store";
import type { TokenIdentifier, Recipe, ItemInventory, Inventory } from "@canisters/accessories/accessories.did.d";

export const inventory = writable<InventoryStore>(undefined);

actors.subscribe(async ({ accessoriesActor }) => {
  if (accessoriesActor) {
    const result = await accessoriesActor.getInventory();
    if ("ok" in result) {
      inventory.set(result.ok);
    } else {
      throw new Error("Could not get inventory");
    }
  }
});

/* 
  Returns a list of materials [Name, TokenIdentifier] from the inventory
*/
export function getMaterials(): Array<[string, TokenIdentifier]> {
  var materials = [];
  let keys = Object.keys(get(inventory));
  keys.forEach((key) => {
    if ("Material" in get(inventory)[key]) {
      materials.push([get(inventory)[key].Material.name.toLowerCase(), get(inventory)[key].Material.tokenIdentifier]);
    }
  });
  return materials;
}

/* 
  Returns a list of accessories [Name, TokenIdentifier] from the inventory
*/

export function getAccessories(): Array<[string, TokenIdentifier]> {
  var accessories = [];
  let keys = Object.keys(get(inventory));
  keys.forEach((key) => {
    if (inventory[key].Accessory) {
      accessories.push([get(inventory)[key].Accessory.name.toLowerCase(), get(inventory)[key].Accessory.tokenIdentifier]);
    }
  });
  return accessories;
}

export type RecipeAnswer = { ok: string[] } | { err: string[] };

/* Get the name of an item (material or accessory) */
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

export function checkRecipe(recipe: Recipe): RecipeAnswer {
  let materials = getMaterials();
  console.log("My materials", materials);
  let missingMaterials = [];
  let tokens = [];
  for (let i = 0; i < recipe.length; i++) {
    const name_material = recipe[i];
    console.log("Looking for", name_material, "in", i);
    const potential_material = materials.find(([name, tokenIdentifier]) => name_material === name);
    console.log("Potential material", potential_material, "in", i);
    if (!potential_material) {
      missingMaterials.push(name_material);
    } else {
      tokens.push(potential_material[1]);
      materials = materials.filter(([name, tokenIdentifier]) => tokenIdentifier !== potential_material[1]);
    }
  }
  if (missingMaterials.length > 0) {
    return { err: missingMaterials };
  } else {
    return { ok: tokens };
  }
}

export async function updateInventory(): Promise<void> {
  const { accessoriesActor } = get(actors);
  if (!accessoriesActor) {
    throw new Error("No accessories actor");
  }
  const result = await accessoriesActor.getInventory();
  if ("ok" in result) {
    inventory.set(result.ok);
  } else {
    throw new Error("Could not get inventory");
  }
}
