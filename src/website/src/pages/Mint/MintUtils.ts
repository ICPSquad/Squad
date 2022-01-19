import { ComponentList } from "../../types/component";
import store from "../../store";

export function fromPropsTitleToRightAction(
  title: string,
  component_selected: ComponentList
): void {
  switch (title) {
    case "Background 🌈":
      store.commit("setBackground", component_selected);
      break;
    case "Profile 👤":
      store.commit("setProfile", component_selected);
      break;
    case "Ears 👂":
      store.commit("setEars", component_selected);
      break;
    case "Eyes 👀":
      store.commit("setEyes", component_selected);
      break;
    case "Nose 👃":
      store.commit("setNose", component_selected);
      break;
    case "Mouth 👄":
      store.commit("setMouth", component_selected);
      break;
    case "Hairs 💇":
      store.commit("setHairs", component_selected);
      break;
    case "Clothes 👔":
      store.commit("setClothes", component_selected);
      break;
    case "Accessories 🎩":
      store.commit("setAccessory", component_selected);
    default:
      console.log("Not detected, what is that ?");
  }
}
