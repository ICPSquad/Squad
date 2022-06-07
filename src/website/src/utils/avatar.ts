import type { AvatarComponents } from "@src/types/avatar";
import type { AvatarColors } from "@src/types/color";
import type { AvatarRendering, Colors, Style } from "@canisters/avatar/avatar.did.d";

/* 
    Convert the AvatarRendering object that we query from the avatar canister to the AvatarComponents & AvatarColors objects that we use in the frontend for the rendering engine of the avatar.
*/
export function renderingToColorsAndComponents(rendering: AvatarRendering): [AvatarColors, AvatarComponents] {
  const colors: AvatarColors = createColors(rendering.style);
  const slots = rendering.slots;
  const components: AvatarComponents = {
    background: rendering.background,
    hairs: rendering.hair,
    eyes: rendering.eyes,
    nose: rendering.nose,
    mouth: rendering.mouth,
    ears: rendering.ears,
    clothes: rendering.cloth,
    profile: rendering.profile,
  };
  if (slots.Hat.length > 0) {
    components.hat = slots.Hat[0];
  }
  if (slots.Body.length > 0) {
    components.body = slots.Body[0];
  }
  if (slots.Face.length > 0) {
    components.face = slots.Face[0];
  }
  if (slots.Eyes.length > 0) {
    components.glasses = slots.Eyes[0];
  }
  if (slots.Misc.length > 0) {
    components.misc = slots.Misc[0];
  }
  return [colors, components];
}

function createColors(style: Style): AvatarColors {
  if ("Old" in style) {
    return createColorsOld(style.Old);
  } else if ("Colors" in style) {
    return createColorsNew(style.Colors);
  }
}

function createColorsNew(colors: Colors): AvatarColors {
  let avatar_colors = {};
  colors.forEach((color) => {
    avatar_colors[minimizeFirstLetter(color.spot)] = color.color;
  });
  //@ts-ignore
  return avatar_colors;
}

function minimizeFirstLetter(word: string) {
  return word.charAt(0).toLowerCase() + word.slice(1);
}

function createColorsOld(style: string): AvatarColors {
  let colors: AvatarColors = {
    background: [findColorValue("background", "r", style), findColorValue("background", "g", style), findColorValue("background", "b", style), 0.5],
    hairs: [findColorValue("hairs", "r", style), findColorValue("hairs", "g", style), findColorValue("hairs", "b", style), 100],
    eyes: [findColorValue("eyes", "r", style), findColorValue("eyes", "g", style), findColorValue("eyes", "b", style), 100],
    eyebrows: [findColorValue("eyebrows", "r", style), findColorValue("eyebrows", "g", style), findColorValue("eyebrows", "b", style), 100],
    eyeliner: [findColorValue("eyeliner", "r", style), findColorValue("eyeliner", "g", style), findColorValue("eyeliner", "b", style), 100],
    clothes: [findColorValue("clothes", "r", style), findColorValue("clothes", "g", style), findColorValue("clothes", "b", style), 100],
    skin: [findColorValue("skin", "r", style), findColorValue("skin", "g", style), findColorValue("skin", "b", style), 100],
  };
  return colors;
}

function findColorValue(slot: string, rgb: string, style: string): number {
  if (slot === "skin" || slot === "clothes") {
    let name = "--" + "color_" + slot + " :rgb(";
    let value_rgb = style.substring(style.indexOf(name) + name.length);
    value_rgb = value_rgb.substring(0, value_rgb.indexOf(";"));
    let value_r = value_rgb.substring(0, value_rgb.indexOf(","));
    let value_g = value_rgb.substring(value_rgb.indexOf(",") + 1, value_rgb.indexOf(",", value_rgb.indexOf(",") + 1));
    let value_b = value_rgb.substring(value_rgb.indexOf(",", value_rgb.indexOf(",") + 1) + 1, value_rgb.indexOf(")"));
    if (rgb === "r") {
      return Number(value_r);
    }
    if (rgb === "g") {
      return Number(value_g);
    }
    if (rgb === "b") {
      return Number(value_b);
    }
  }
  let name = "--" + "color" + "_" + slot + "_" + rgb + ":";
  let value = style.substring(style.indexOf(name) + name.length);
  value = value.substring(0, value.indexOf(";"));
  return parseInt(value);
}

/* Returns a boolean indicating if an accessory is equipped on an avatar  */
export function isEquipped(name: string, avatar: AvatarComponents): boolean {
  if (avatar.body === name || avatar.face === name || avatar.hat === name || avatar.glasses === name || avatar.misc === name) {
    return true;
  }
  return false;
}
