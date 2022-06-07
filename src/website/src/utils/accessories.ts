import type { TokenIdentifier, Result } from "@canisters/accessories/accessories.did.d";
import { get } from "svelte/store";
import { actors } from "@src/store/actor";

export function wearAccessory(tokenId: TokenIdentifier, avatar: TokenIdentifier): Promise<Result> {
  return get(actors).accessoriesActor.wear_accessory(tokenId, avatar);
}

export function removeAccessory(tokenId: TokenIdentifier, avatar: TokenIdentifier): Promise<Result> {
  return get(actors).accessoriesActor.remove_accessory(tokenId, avatar);
}
