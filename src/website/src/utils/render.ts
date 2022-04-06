import {
  AvatarRequest,
  ComponentRequest,
} from "../../../declarations/avatar/avatar.did.d";
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

    // Adding classes to the <USE> tags
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

  svgElem.style.setProperty("--color_background_r", `${avatar.Colors.Background[0]}`);
  svgElem.style.setProperty("--color_background_g", `${avatar.Colors.Background[1]}`);
  svgElem.style.setProperty("--color_background_b", `${avatar.Colors.Background[2]}`);
  svgElem.style.setProperty("--color_skin",`rgb(${avatar.Colors.Skin[0]}, ${avatar.Colors.Skin[1]}, ${avatar.Colors.Skin[2]})`);
  svgElem.style.setProperty("--color_clothes",`rgb(${avatar.Colors.Clothes[0]}, ${avatar.Colors.Clothes[1]}, ${avatar.Colors.Clothes[2]})`);
  svgElem.style.setProperty("--color_eyes_r", `${avatar.Colors.Eyes[0]}`);
  svgElem.style.setProperty("--color_eyes_g", `${avatar.Colors.Eyes[1]}`);
  svgElem.style.setProperty("--color_eyes_b", `${avatar.Colors.Eyes[2]}`);
  svgElem.style.setProperty("--color_hairs_r", `${avatar.Colors.Hairs[0]}`);
  svgElem.style.setProperty("--color_hairs_g", `${avatar.Colors.Hairs[1]}`);
  svgElem.style.setProperty("--color_hairs_b", `${avatar.Colors.Hairs[2]}`);
  svgElem.style.setProperty("--color_eyebrows_r", `${avatar.Colors.Eyebrows[0]}`);
  svgElem.style.setProperty("--color_eyebrows_g", `${avatar.Colors.Eyebrows[1]}`);
  svgElem.style.setProperty("--color_eyebrows_b", `${avatar.Colors.Eyebrows[2]}`);
  svgElem.style.setProperty("--color_eyeliner_r", `${avatar.Colors.Eyeliner[0]}`);
  svgElem.style.setProperty("--color_eyeliner_g", `${avatar.Colors.Eyeliner[1]}`);
  svgElem.style.setProperty("--color_eyeliner_b", `${avatar.Colors.Eyeliner[2]}`);

  div.appendChild(svgElem);
};
