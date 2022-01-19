import {
  Inventory,
  AssetInventoryType,
} from "declarations/materials/materials.did";
// Get number materials

type inventoryObjectForComponent = {
  Cloth: number;
  Wood: number;
  Glass: number;
  Metal: number;
  Circuit: number;
  Stone: number;
};

type AccesoryForComponent = [string, string]; // [tokenId, name]
type arrayObjectForComponent = AccesoryForComponent[];

export function getObjectForMaterialComponent(
  inventory: Inventory
): inventoryObjectForComponent {
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

export function getArrayforAccessoryComponent(
  inventory: Inventory
): arrayObjectForComponent {
  var arrayObject: arrayObjectForComponent = [];
  inventory.forEach((element) => {
    let category: AssetInventoryType = element.category;
    //@ts-ignore
    if ("Accessory" in category) {
      arrayObject.push([element.token_identifier, element.name]);
    }
  });
  return arrayObject;
}

export function isAccessoryInInventory(
  string: string,
  inventory: Inventory
): boolean {
  var isAccessory: boolean = false;
  inventory.forEach((element) => {
    if (element.name === string) {
      isAccessory = true;
    }
  });
  return isAccessory;
}

export function getTokenIdentifier(
  string: string,
  inventory: Inventory
): string {
  var tokenIdentifier: string = "null";
  inventory.forEach((element) => {
    if (element.name === string) {
      tokenIdentifier = element.token_identifier;
    }
  });
  return tokenIdentifier;
}
