import { AvatarRequest, ComponentRequest } from "declarations/nft/nft.did.d";
import { buildRequestFromAvatar, Avatar } from "../types/avatar";

export function removeAllChildren(element: HTMLElement) {
  if (!element) return;
  while (element.firstChild) {
    element.removeChild(element.firstChild);
  }
}

export const renderAvatar = (div: HTMLElement, avatar: Avatar) => {
  removeAllChildren(div);

  // Create the svg element and configures its viewbox
  var svgElem = document.createElementNS("http://www.w3.org/2000/svg", "svg");
  svgElem.setAttribute("viewBox", "0 0 800 800");

  let request: AvatarRequest | null = buildRequestFromAvatar(avatar);
  if (request === null) {
    return;
  }

  let array_request: Array<ComponentRequest> = request.components;

  // Order the componentsrequest by their layer
  let compareFn = (a: ComponentRequest, b: ComponentRequest) => {
    return a.layer - b.layer;
  };
  array_request.sort(compareFn);

  // Create the layers
  array_request.forEach((component) => {
    let layer = document.createElementNS("http://www.w3.org/2000/svg", "use");
    layer.setAttributeNS(
      "http://www.w3.org/1999/xlink",
      "href",
      `#${component.name}`
    );

    // Adding classes the the <USE> tags
    if (
      component.name == "Business-body" ||
      component.name == "Punk-body" ||
      component.name == "Miss-body"
    ) {
      svgElem.classList.add(component.name);
    } else if (component.name.length == 1) {
      layer.classList.add(`clothing-${component.name}`);
    } else {
      component.name.split("-").forEach((word) => {
        layer.classList.add(word);
      });
      layer.classList.add(component.name);
    }

    svgElem.appendChild(layer);
  });

  div.appendChild(svgElem);
};
