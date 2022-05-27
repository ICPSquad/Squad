import { getComponentByName } from "@src/utils/list";

/*  Generate the class to be applied to any component (accessories included).
    @param {string} name : The name of the component (as specified in the manifest)
    @param {string} layer : The layer of the component 
*/
export function componentToClass(name: string, layer: number): string {
  let { category, type } = getComponentByName(name);
  if (category === "avatar") {
    if (type === "profile") {
      if (layer == 20) {
        return "Body" + " " + capitalizeFirstLetter(replaceDash(name)) + " " + capitalizeFirstLetter(name);
      } else if (layer == 35) {
        return "Head" + " " + capitalizeFirstLetter(replaceDash(name)) + " " + capitalizeFirstLetter(name);
      } else if (layer == 25) {
        return "Neck" + " " + capitalizeFirstLetter(replaceDash(name)) + " " + capitalizeFirstLetter(name);
      } else {
        throw new Error("Invalid layer for a profile");
      }
    } else if (type === "clothes") {
      return "clothing" + " " + "clothing" + `-${name}` + " " + name;
    } else if (type === "hair") {
      if (layer == 90) {
        return "Hair-above" + " " + capitalizeFirstLetter(replaceDash(name)) + " " + capitalizeFirstLetter(name);
      } else if (layer == 10) {
        return "Hair-behind" + " " + capitalizeFirstLetter(replaceDash(name)) + " " + capitalizeFirstLetter(name);
      } else {
        return "Hair" + " " + capitalizeFirstLetter(replaceDash(name)) + " " + capitalizeFirstLetter(name);
      }
    } else {
      return capitalizeFirstLetter(type) + " " + capitalizeFirstLetter(replaceDash(name)) + " " + capitalizeFirstLetter(name);
    }
  } else if (category === "accessory") {
    return capitalizeFirstLetter(type) + " " + capitalizeFirstLetter(name) + "-" + layer.toString();
  }
}

function capitalizeFirstLetter(string: string) {
  return string.charAt(0).toUpperCase() + string.slice(1);
}

function replaceDash(string: string) {
  return string.replace(/-/g, " ");
}

/* 
    Generate the class to add to the avatar based on his profile. DO NOT FORGET OTHERWISE CSS SELECTORS WONT WORK.
    @param {string} profile : The name of the profile of the avatar (as specified in the manifest)
*/
export function profileToClass(name: string): string {
  switch (name) {
    case "business-profile":
      return "Business-body";
    case "punk-profile":
      return "Punk-body";
    case "miss-profile":
      return "Miss-body";
    default:
      throw new Error("Invalid profile");
  }
}
