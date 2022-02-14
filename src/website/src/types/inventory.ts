import { Inventory, AssetInventoryType, StreamingCallback } from "declarations/accessories/accessories.did";
// Get number materials

type inventoryObjectForComponent = {
  Cloth: number;
  Wood: number;
  Glass: number;
  Metal: number;
  Circuit: number;
  Stone: number;
};

export type AccesoryInfos = {
  name: string;
  token_identifier: string;
  equipped: boolean;
};
type AccessoryList = AccesoryInfos[];

export function getObjectForMaterialComponent(inventory: Inventory): inventoryObjectForComponent {
  var inventoryObject: inventoryObjectForComponent = {
    Cloth: 0,
    Wood: 0,
    Glass: 0,
    Metal: 0,
    Circuit: 0,
    Stone: 0,
  };
  inventory.forEach((element) => {
    if (element.name === "Cloth") {
      inventoryObject.Cloth += 1;
    }
    if (element.name === "Wood") {
      inventoryObject.Wood += 1;
    }
    if (element.name === "Glass") {
      inventoryObject.Glass += 1;
    }
    if (element.name === "Metal") {
      inventoryObject.Metal += 1;
    }
    if (element.name === "Circuit") {
      inventoryObject.Circuit += 1;
    }
    if (element.name === "Dfinity-stone") {
      inventoryObject.Stone += 1;
    }
  });
  return inventoryObject;
}

export function AccessoryListFromInventory(inventory: Inventory): AccessoryList {
  var arrayObject: AccessoryList = [];
  inventory.forEach((element) => {
    let category: AssetInventoryType = element.category;
    if ("Accessory" in category) {
      //@ts-ignore
      arrayObject.push({ name: element.name, token_identifier: element.token_identifier, equipped: element.category.Accessory });
    }
  });
  console.log("arrayObject", arrayObject);
  return arrayObject;
}

export function isAccessoryInInventory(string: string, inventory: Inventory): boolean {
  var isAccessory: boolean = false;
  inventory.forEach((element) => {
    if (element.name === string) {
      isAccessory = true;
    }
  });
  return isAccessory;
}

export function getTokenIdentifier(string: string, inventory: Inventory): string {
  var tokenIdentifier: string = "null";
  inventory.forEach((element) => {
    if (element.name === string) {
      tokenIdentifier = element.token_identifier;
    }
  });
  return tokenIdentifier;
}

export function getTokensAccessory(inventory: Inventory): string[] {
  var tokens: string[] = [];
  inventory.forEach((element) => {
    console.log(element);
    tokens.push(element.token_identifier);
  });
  return tokens;
}

// Used to update the Accessory List that is loaded once we have equipped/desequipped an accessory and change the equipped field of the correponding accessory
export function changeInventory(token_identifier: string, inventory: Inventory): Inventory {
  var newInventory: Inventory = [];
  inventory.forEach((element) => {
    if (element.token_identifier === token_identifier) {
      //@ts-ignore
      newInventory.push({ name: element.name, token_identifier: element.token_identifier, category: { Accessory: !element.category.Accessory } });
    } else {
      newInventory.push(element);
    }
  });
  return newInventory;
}
