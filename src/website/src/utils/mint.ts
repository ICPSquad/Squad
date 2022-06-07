import type { AvatarComponents } from "../types/avatar.d";
import type { AvatarColors } from "../types/color.d";
import { get } from "svelte/store";
import { actors } from "@src/store/actor";
import type { MintInformation, Colors, MintResult as MintResultAvatar } from "@canisters/avatar/avatar.did.d";
import type { Result_3 as MintResultAccessory } from "@canisters/accessories/accessories.did.d";

/* 
    Create the mint request to send to the canister.
    @param {AvatarComponents} components - The components selected by the user.
    @param {AvatarColors} colors - The colors selected by the user.
*/

function createMintRequest(components: AvatarComponents, color: AvatarColors): MintInformation {
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
    // DO NOT TOUCH. THIS IS A DIRTY FIX. NEED TO BE CHANGED FOR SEASON 1.
    if (key == "background") {
      result.push({
        color: [color[key][0], color[key][1], color[key][2], 100],
        spot: capitalizeFirstLetter(key),
      });
    } else {
      result.push({
        color: color[key],
        spot: capitalizeFirstLetter(key),
      });
    }
  }
  return result;
}

/* This function is needed due to the discrepancy between items/components names in the frontend and as upload in the canister (accessory and avatar)  */
export function capitalizeFirstLetter(word: string) {
  return word.charAt(0).toUpperCase() + word.slice(1);
}

export async function mintRequestAvatar(components: AvatarComponents, color: AvatarColors, invoiceId?: number): Promise<MintResultAvatar> {
  let id: [bigint] | [] = invoiceId ? [BigInt(invoiceId)] : [];
  let mint_request = createMintRequest(components, color) as MintInformation;
  const result = await get(actors).avatarActor.mint(createMintRequest(components, color), id);
  return result;
}

export async function mintRequestAccessory(name: string, invoiceId: number): Promise<MintResultAccessory> {
  const result = await get(actors).accessoriesActor.create_accessory(name, BigInt(invoiceId));
  return result;
}
