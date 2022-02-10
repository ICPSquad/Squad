//Create the full svg from the layers

import { HttpAgent, Actor } from "@dfinity/agent";
import { AvatarPreviewNew } from "@/declarations/avatar/avatar.did";
import { LayerId } from "@/declarations/avatar/avatar.did";

//  Get the final svg to display from layers, body_name & style.
export function constructSVG(layers: Array<[LayerId, string]>, body_name: string, style: string): string {
  let svg = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 800 800" class='${body_name}'>`;
  svg += style;
  // Suppose the array is already ordered by layerid
  layers.forEach((layer) => {
    svg += layer[1];
  });
  return svg + "</svg>";
}
