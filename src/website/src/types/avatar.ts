import { ComponentList } from "./component";
import { AvatarRequest, Color } from "declarations/event/event.did.d";
import { ComponentRequest } from "declarations/nft/nft.did.d";
import { ColorList, createColorsAvatarRequest } from "./color";

export type Avatar = {
  Background: ComponentList | null;
  Profile: ComponentList | null;
  Ears: ComponentList | null;
  Eyes: ComponentList | null;
  Nose: ComponentList | null;
  Mouth: ComponentList | null;
  Hairs: ComponentList | null;
  Clothes: ComponentList | null;
  Accessory: ComponentList | null;
  Colors: ColorList;
};

export function buildRequestFromAvatar(avatar: Avatar): AvatarRequest | null {
  let requestFinal: ComponentRequest[] = [];
  for (const key in avatar) {
    if (!(key === "level" || key === "Colors") && avatar[key] !== null) {
      let request = buildComponentRequestFromComponentList(avatar[key]);
      //@ts-ignore
      requestFinal = requestFinal.concat(request);
    }
  }
  let colors: Array<{ color: Color; spot: string }> =
    createColorsAvatarRequest();

  return {
    //@ts-ignore
    components: requestFinal,
    colors,
  };
}

function buildComponentRequestFromComponentList(
  componentList: ComponentList
): ComponentRequest[] {
  if (componentList.components.length === 1) {
    let request: ComponentRequest = {
      name: componentList.components[0].name,
      layer: componentList.components[0].layer,
    };
    return [request];
  } else {
    let array_request: ComponentRequest[] = [];
    componentList.components.forEach((component) => {
      let request: ComponentRequest = {
        name: component.name,
        layer: component.layer,
      };
      array_request.push(request);
    });
    return array_request;
  }
}
