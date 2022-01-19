// Goal of this module is to deconstruct the svg that is received as raw text from the nft canister
// SVG -> [{content : string, layer : number}] so we can easily insert accessories and rebuild the whole svg

import { def } from "@vue/shared";
import store from "../store";
import { Slots } from "../types/accessories";
export type SvgLayer = {
  content: string;
  layer: number;
};

export type SvgDeconstructed = Array<SvgLayer>;

// Convert a template string into HTML DOM nodes
function stringToHTML(string: string): HTMLElement {
  var parser = new DOMParser();
  var doc = parser.parseFromString(string, "text/html");
  return doc.body;
}

function childToSvgLayer(child: ChildNode): SvgLayer | null {
  if (child.nodeType === 3) {
    return null;
  }
  //@ts-ignore
  if (!child.classList) {
    return null;
  }
  //@ts-ignore
  let classList = child.classList;

  let layer = nameToLayer(classList[0]);
  //@ts-ignore
  let content = child.outerHTML;
  return {
    content,
    layer,
  };
}

function nameToLayer(name: string): number {
  //TODO : miss hair behind/above
  switch (name) {
    case "Background":
      return 5;
    case "Hair-behind":
      return 10;
    case "Body":
      return 20;
    case "Ears":
      return 30;
    case "Head":
      return 35;
    case "Mouth":
      return 45;
    case "Eyes":
      return 50;
    case "Nose":
      return 55;
    case "clothing":
      return 70;
    case "Hair":
      return 75;
    case "Hair-above":
      return 90;
    case "Eyes":
      return 80;
    case "Hat":
      return 85;
    default:
      return 1;
  }
}

function orderSvgLayers(svg: Array<SvgLayer>): Array<SvgLayer> {
  return svg.sort((a, b) => a.layer - b.layer);
}

export const deconstruct = (svg: string): Array<SvgLayer> => {
  let array: SvgLayer[] = [];
  const svgHTML = stringToHTML(svg);
  let temp_childs = svgHTML.childNodes;
  console.log(temp_childs);
  let childs = temp_childs[0].childNodes;
  console.log(childs);
  childs.forEach((child) => {
    let element = childToSvgLayer(child);
    if (element != null) {
      array.push(element);
    }
  });
  console.log("Array deconstucted", array);
  return array;
};

const reconstruct = (
  deconstructed: SvgDeconstructed | null,
  slots: Slots
): string => {
  if (deconstructed == null) {
    return "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 800 800'></svg>";
  }
  let body = findBodyType();
  if (body === "") {
    throw new Error("Could not find body type");
  }
  let svg = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 800 800" class='${body}'>`;
  let accessory_layers = slotsToSvg(slots);
  const new_deconstruted = [...deconstructed, ...accessory_layers];
  let ordered = orderSvgLayers(new_deconstruted);
  ordered.forEach((layer) => {
    svg += layer.content;
  });
  return svg + "</svg>";
};

// This function is used to get the raw <g> content of an accesory based on its name, by looking through the DOM and using the symbol in <defs>

const getContentFromSymbol = (name: string): string => {
  let element = document.getElementById(name);
  if (element == null) {
    throw new Error("Could not find symbol with id " + name);
  }
  let content = element.innerHTML;
  return content;
};

export const redrawSvg = (): string => {
  const raw_svg = store.getters.getRawAvatar;
  const slots = store.getters.getSlots;
  const deconstructed = deconstruct(raw_svg);
  const reconstructed = reconstruct(deconstructed, slots);
  return reconstructed;
};

function slotsToSvg(slots: Slots): Array<SvgLayer> {
  var layers: SvgLayer[] = [];
  for (let slot in slots) {
    if (slots[slot as keyof Slots] != null) {
      if (slot == null) {
        throw new Error("Slot is null");
      }
      let components = slots[slot as keyof Slots]!.components;
      components.forEach((component) => {
        let content = getContentFromSymbol(component.name);
        layers.push({
          content,
          layer: component.layer,
        });
      });
    }
  }
  return layers;
}

export function findBodyType(): string {
  const svg = store.getters.getRawAvatar;
  if (!svg) {
    throw new Error("No raw avatar found");
  }
  // We only want to keep the <svg> tag to avoid false positives
  const substring = svg.substring(0, svg.indexOf(">") + 1);
  console.log("Substring", substring);
  if (substring.includes("Punk-body")) {
    return "Punk-body";
  } else if (substring.includes("Miss-body")) {
    return "Miss-body";
  } else if (substring.includes("Business-body")) {
    return "Business-body";
  } else {
    return "";
  }
}
