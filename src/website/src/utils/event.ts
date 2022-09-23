import type { ExtendedEvent } from "@canisters/hub/hub.did.d";
import type { Event } from "@psychedelic/cap-js";
import { Principal } from "@dfinity/principal";
import { e8sToICP } from "./stats";

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
  console.log("Event", event);
  let name = _getName(event);
  console.log("Name: " + name);
  if (name === "") {
    return true;
  }
  for (let material of materials) {
    if (name.includes(material)) {
      return false;
    }
  }
  return true;
}

/* 
  Used to filter out details of the event in the submenu
*/

export function _getNameOpt(event: Event): string | null {
  let details = event.details;
  let length = details.length;
  for (let i = 0; i < length; i++) {
    if (details[i][0] == "name") {
      if (details[i][1].Text) {
        return details[i][1].Text;
      }
    }
  }
  return null;
}

export function _getFromOpt(event: Event): string | null {
  let details = event.details;
  let length = details.length;
  for (let i = 0; i < length; i++) {
    if (details[i][0] == "from") {
      if (details[i][1].Text) {
        return details[i][1].Text;
      }
    }
  }
  return null;
}

export function _getToOpt(event: Event): string | null {
  let details = event.details;
  let length = details.length;
  for (let i = 0; i < length; i++) {
    if (details[i][0] == "to") {
      if (details[i][1].Text) {
        return details[i][1].Text;
      }
    }
  }
  return null;
}

export function _getPriceOpt(event: Event): number | null {
  let details = event.details;
  console.log("Details: ", details);
  let length = details.length;
  for (let i = 0; i < length; i++) {
    if (details[i][0] == "price") {
      console.log("Found price: ", details[i]);
      if (details[i][1].U64) {
        console.log("Found price: ", details[i][1].U64);
        return e8sToICP([details[i][1].U64]);
      }
    }
  }
  return null;
}

export function _getTokenIdOpt(event: Event): string | null {
  let details = event.details;
  let length = details.length;
  for (let i = 0; i < length; i++) {
    if (details[i][0] == "token") {
      if (details[i][1].Text) {
        return details[i][1].Text;
      }
    }
  }
  return null;
}
