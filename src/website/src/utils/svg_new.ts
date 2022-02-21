//Create the full svg from the layers

import { HttpAgent, Actor } from "@dfinity/agent";
import { AvatarPreviewNew } from "@/declarations/avatar/avatar.did";
import { LayerId } from "@/declarations/avatar/avatar.did";
import { AccesoryInfos } from "../types/inventory";
import { nameToLayerId } from "./list";
import store from "../store";

//  Get the final svg to display from layers, body_name & style.
export function constructSVG(layers: Array<[LayerId, string]>, body_name: string, style: string, accessory?: AccesoryInfos): string {
  var layers_copy = [...layers];
  if (accessory && !accessory.equipped) {
    let layer = nameToLayerId(accessory.name);
    let content = document.createElementNS("http://www.w3.org/2000/svg", "use");
    content.setAttributeNS("http://www.w3.org/1999/xlink", "href", `#${accessory.name}`);
    if (layer) {
      layers_copy.push([BigInt(layer), content.outerHTML]);
    }
  }
  let svg = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 800 800" class='${body_name}'>`;
  svg += style;

  // Check if we need to hide clothing (e.g when we have just equipped something on body)
  //@ts-ignore
  if (store.state.auth.hideClothing) {
    svg += "<style>.clothing{visibility : hidden;}</style>";
  }
  // Order arrray by layerId
  layers_copy.sort((a, b) => {
    return Number(a[0] - b[0]);
  });
  // Add <g> for each layer
  layers_copy.forEach((layer) => {
    svg += layer[1];
  });
  return svg + "</svg>";
}

export function addAccessoryLayers(layers: Array<[LayerId, string]>, name: string): Array<[LayerId, string]> {
  let layer = nameToLayerId(name);
  if (layer) {
    layers.push([BigInt(layer), `<use xlink:href="#${name}"/>`]);
  }
  return layers;
}

export function removeAccessoryLayers(layers: Array<[LayerId, string]>, name: string): Array<[LayerId, string]> {
  let layer = nameToLayerId(name);
  console.log("Layer", layer);
  if (layer) {
    layers = layers.filter((l) => {
      //@ts-ignore
      return l[0] != BigInt(layer);
    });
  }
  console.log("removeAccessoryLayers", layers);
  return layers;
}
