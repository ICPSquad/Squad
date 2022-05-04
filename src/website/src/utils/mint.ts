import type { AvatarComponents } from "../types/avatar.d";
import type { AvatarColors } from "../types/color.d";
import type { MintInformation, Colors } from "@canisters/hub/hub.did.d";

/* 
    Create the mint request to send to the canister.
    @param {AvatarComponents} components - The components selected by the user.
    @param {AvatarColors} colors - The colors selected by the user.
*/

export function createMintRequest(components: AvatarComponents, color: AvatarColors): MintInformation {
  return {
    mouth: components.mouth,
    background: components.background,
    ears: components.ears,
    eyes: components.eyes,
    hair: components.hairs,
    cloth: components.clothes,
    nose: components.nose,
    profile: components.profile,
    colors: createColors(color),
  };
}

/* 
    Create the Colors object that is used in the MintInformation based on the AvatarColors object that is used 
    to render the avatar in the RenderAvatar component.
*/
function createColors(color: AvatarColors): Colors {
  var result = [];
  for (let key in color) {
    result.push({
      color: color[key],
      spot: key,
    });
  }
  return result;
}
