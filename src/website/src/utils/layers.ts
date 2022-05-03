import { getLayers } from "@utils/list";
import type { AvatarComponents } from "../types/avatar";

/*
 * Based on the infomations that constitute the avatar, this function returns a sorted array containing the layers of the avatar along with their layer id.
 * [["background-base", 5] ["business-body", 20] ... ["hair-7", 75]]
 */

export function getSortedComponents(avatar: AvatarComponents): [string, number][] {
  var result = [];
  for (var key in avatar) {
    if (avatar[key]) {
      try {
        let layers = getLayers(avatar[key] as keyof AvatarComponents);
        layers.forEach((layer) => {
          result.push([avatar[key], layer]);
        });
      } catch (e) {
        console.error(e);
      }
    }
  }
  // Order all elements by their layer id
  result.sort((a, b) => {
    return a[1] - b[1];
  });
  return result;
}
