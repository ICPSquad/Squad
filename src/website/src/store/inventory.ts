import { writable } from "svelte/store";
import { actors } from "./actor";
import type { InventoryStore } from "./types/inventory-store";

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
