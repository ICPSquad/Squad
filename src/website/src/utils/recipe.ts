import { Inventory, Recipe } from "declarations/accessories/accessories.did";

// This function will create a list of token identifier belonging to the inventory and suitable for the recipe
export function getTokensFromInventory(recipe: Recipe, inventory: Inventory): string[] | null {
  var tokens: string[] = [];
  var current_inventory = inventory;
  const length = recipe.length;
  for (let i = 0; i < length; i++) {
    let { token_identifier, new_inventory } = removeFromInventory(recipe[i], current_inventory);
    if (token_identifier === null) {
      return null;
    }
    tokens.push(token_identifier);
    current_inventory = new_inventory;
  }
  return tokens;
}

// Utility function to extract a specific material from the inventory and
function removeFromInventory(element: string, inventory: Inventory): { token_identifier: string | null; new_inventory: Inventory } {
  let length = inventory.length;
  for (let i = 0; i < length; i++) {
    let asset = inventory[i];
    if (asset.name == element) {
      return {
        token_identifier: asset.token_identifier,
        new_inventory: inventory.slice(0, i).concat(inventory.slice(i + 1)),
      };
    }
  }
  return {
    token_identifier: null,
    new_inventory: inventory,
  };
}
