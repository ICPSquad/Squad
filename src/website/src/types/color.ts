import type { Color } from "../../../declarations/avatar/avatar.did";

export type ColorList = {
  Skin: Color;
  Hairs: Color;
  Eyes: Color;
  Eyebrows: Color;
  Background: Color;
  Eyeliner: Color;
  Clothes: Color;
};

export const colorCategoryDisplayName = {
  Skin: "Skin",
  Hairs: "Hair",
  Eyes: "Eyes",
  Eyebrows: "Eyebrows",
  Background: "Background",
  Eyeliner: "Eye shadow",
  Clothes: "Clothes",
};

export const suggestedColors = {
  Skin: [
    [65, 22, 3, 1],
    [167, 76, 1, 1],
    [244, 175, 118, 1],
    [254, 214, 167, 1],
  ],
  Hairs: [
    [38, 13, 3, 1],
    [77, 25, 5, 1],
    [167, 76, 1, 1],
    [240, 71, 71, 1],
    [240, 208, 163, 1],
    [176, 176, 176],
    [251, 157, 212, 1],
    [112, 247, 85, 1],
  ],
  Eyes: [
    [30, 112, 220, 1],
    [33, 0, 199, 1],
    [14, 185, 105, 1],
    [73, 141, 28, 1],
    [77, 25, 5, 1],
    [167, 76, 1, 1],
    [167, 115, 53, 1],
  ],
  Eyebrows: [
    [38, 13, 3, 1],
    [77, 25, 5, 1],
    [167, 76, 1, 1],
    [240, 71, 71, 1],
    [240, 208, 163, 1],
    [176, 176, 176],
    [251, 157, 212, 1],
    [112, 247, 85, 1],
  ],
  Background: [
    [164, 21, 143, 1],
    [244, 126, 142, 1],
    [30, 112, 220, 1],
    [33, 0, 199, 1],
    [14, 185, 105, 1],
    [73, 141, 28, 1],
    [255, 187, 0, 1],
    [168, 126, 11, 1],
    [176, 176, 176],
  ],
  Eyeliner: [
    [164, 21, 143, 1],
    [244, 126, 142, 1],
    [30, 112, 220, 1],
    [33, 0, 199, 1],
    [14, 185, 105, 1],
    [73, 141, 28, 1],
    [255, 187, 0, 1],
    [168, 126, 11, 1],
    [176, 176, 176],
  ],
  Clothes: [
    [164, 21, 143, 1],
    [244, 126, 142, 1],
    [30, 112, 220, 1],
    [33, 0, 199, 1],
    [14, 185, 105, 1],
    [73, 141, 28, 1],
    [255, 187, 0, 1],
    [168, 126, 11, 1],
    [176, 176, 176],
  ],
};

export function changeCSSVariable(new_color: Color, title: string) {
  let root = document.documentElement;
  switch (title) {
    case "Background 🌈":
      root.style.setProperty("--color_background_r", `${new_color[0]}`);
      root.style.setProperty("--color_background_g", `${new_color[1]}`);
      root.style.setProperty("--color_background_b", `${new_color[2]}`);
      return;
    case "Profile 👤":
      root.style.setProperty(
        "--color_skin",
        `rgb(${new_color[0]}, ${new_color[1]}, ${new_color[2]})`
      );
      return;
    case "Clothes 👔":
      root.style.setProperty(
        "--color_clothes",
        `rgb(${new_color[0]}, ${new_color[1]}, ${new_color[2]})`
      );
      return;
    case "Eyes 👀":
      root.style.setProperty("--color_eyes_r", `${new_color[0]}`);
      root.style.setProperty("--color_eyes_g", `${new_color[1]}`);
      root.style.setProperty("--color_eyes_b", `${new_color[2]}`);
      return;
    case "Hairs 💇":
      root.style.setProperty("--color_hairs_r", `${new_color[0]}`);
      root.style.setProperty("--color_hairs_g", `${new_color[1]}`);
      root.style.setProperty("--color_hairs_b", `${new_color[2]}`);
      return;
    case "Eyebrows":
      root.style.setProperty("--color_eyebrows_r", `${new_color[0]}`);
      root.style.setProperty("--color_eyebrows_g", `${new_color[1]}`);
      root.style.setProperty("--color_eyebrows_b", `${new_color[2]}`);
      return;
    case "Eyeliner":
      root.style.setProperty("--color_eyeliner_r", `${new_color[0]}`);
      root.style.setProperty("--color_eyeliner_g", `${new_color[1]}`);
      root.style.setProperty("--color_eyeliner_b", `${new_color[2]}`);
  }
}

export function createColorsAvatarRequest(): Array<{
  color: Color;
  spot: string;
}> {
  let result: Array<{ color: Color; spot: string }> = [];
  // @ts-ignore
  // let colors: ColorList = store.getters.getColors as ColorList;
  let colors: ColorList = {
    Skin: [0, 0, 0, 0],
    Hairs: [0, 169, 252, 1],
    Eyes: [0, 169, 252, 1],
    Eyebrows: [0, 169, 252, 1],
    Background: [0, 169, 252, 1],
    Eyeliner: [0, 169, 252, 1],
    Clothes: [0, 169, 252, 1],
  };
  for (let key in colors) {
    result.push({
      color: colors[key as keyof ColorList],
      spot: key,
    });
  }
  return result;
}

export function changeCSSOpacity(opacity: number) {
  let root = document.documentElement;
  root.style.setProperty("--color_background_a", `${opacity}`);
  return;
}
