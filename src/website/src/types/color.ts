import { Color } from "../../../declarations/avatar/avatar.did";
// import store from "../store";

export type ColorList = {
  Skin: Color;
  Hairs: Color;
  Eyes: Color;
  Eyebrows: Color;
  Background: Color;
  Eyeliner: Color;
  Clothes: Color;
};

export function changeColorInStore(new_color: Color, title: string) {
  switch (title) {
    case "Profile 👤":
      store.commit("setSkinColor", [new_color[0], new_color[1], new_color[2]]);
      return;
    case "Clothes 👔":
      store.commit("setClothesColor", [
        new_color[0],
        new_color[1],
        new_color[2],
      ]);
      return;
    case "Hairs 💇":
      store.commit("setHairColor", [new_color[0], new_color[1], new_color[2]]);
      return;
    case "Eyes 👀":
      store.commit("setEyesColor", [new_color[0], new_color[1], new_color[2]]);
      return;
    case "Eyebrows":
      store.commit("setEyebrowsColor", [
        new_color[0],
        new_color[1],
        new_color[2],
      ]);
      return;
    case "Background 🌈":
      store.commit("setBackgroundColor", [
        new_color[0],
        new_color[1],
        new_color[2],
      ]);
      return;
    case "Eyeliner":
      store.commit("setEyelinerColor", [
        new_color[0],
        new_color[1],
        new_color[2],
      ]);
      return;
  }
}

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
    Skin: [0, 169, 252, 1],
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
