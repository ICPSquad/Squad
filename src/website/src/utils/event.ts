import type { ExtendedEvent } from "@canisters/hub/hub.did.d";
import type { Event } from "@psychedelic/cap-js";
import { Principal } from "@dfinity/principal";

export function _extendEvent(e: Event, collection: Principal): ExtendedEvent {
  return {
    ...e,
    collection: collection,
  };
}

export function _getName(event: Event): string {
  let details = event.details;
  let length = details.length;
  for (let i = 0; i < length; i++) {
    if (details[i][0] == "name") {
      return details[i][1].Text;
    }
  }
  return "";
}

export function _isAccessoryBurnEvent(event: Event): boolean {
  let materials = ["Cloth", "Wood", "Glass", "Metal", "Circuit", "Dfinity-stone", "Cronic-essence", "Punk-essence"];
  if (event.operation != "burn" || event.collection.toString() != Principal.fromText("po6n2-uiaaa-aaaaj-qaiua-cai")) {
    return false;
  }
  let name = _getName(event);
  console.log("Name: " + name);
  if (name === "") {
    return false;
  }
  for (let material of materials) {
    if (name.includes(material)) {
      return false;
    }
  }
  return true;
}

export function _isAccessoryMintEvent(event: Event): boolean {
  let materials = ["Cloth", "Wood", "Glass", "Metal", "Circuit", "Dfinity-stone", "Cronic-essence", "Punk-essence"];
  if (event.operation != "mint" || event.collection.toString() != Principal.fromText("po6n2-uiaaa-aaaaj-qaiua-cai")) {
    return false;
  }
  let name = _getName(event);
  if (name === "") {
    return false;
  }
  for (let material of materials) {
    if (name.includes(material)) {
      return false;
    }
  }
  return true;
}
