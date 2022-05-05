import type { AvatarComponents } from "../types/avatar.d";
import type { AvatarColors } from "../types/color.d";
import { get } from "svelte/store";
import { user } from "@src/store/user";
import { avatar } from "@src/store/avatar";
import { actors } from "@src/store/actor";
import type { MintInformation, Colors, MintResult } from "@canisters/avatar/avatar.did.d";
import type { Invoice__1 as Invoice, Category } from "@canisters/invoice/invoice.did.d";

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

function capitalizeFirstLetter(word: string) {
  return word.charAt(0).toUpperCase() + word.slice(1);
}

export function handleMintRequest(components: AvatarComponents, color: AvatarColors) {
  if (!get(user).loggedIn) {
    throw new Error("Not logged in");
  }
  if (get(avatar).tokenIdentifier) {
    console.log("Token Identifier :", get(avatar).tokenIdentifier);
    throw new Error("You already have an avatar");
  }
}

export async function mintRequest(components: AvatarComponents, color: AvatarColors, invoiceId: number): Promise<MintResult> {
  const result = await get(actors).avatarActor.mint(createMintRequest(components, color), BigInt(invoiceId));
  console.log("Mint result :", result);
  return result;
}
