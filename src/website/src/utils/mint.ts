import type { AvatarComponents } from "../types/avatar.d";
import type { AvatarColors } from "../types/color.d";
import type { MintInformation, Colors, MintResult, Invoice } from "@canisters/hub/hub.did.d";
import type { MintErr } from "@canisters/hub/hub.did.d";
import { get } from "svelte/store";
import { user } from "@src/store/user";
import { avatar } from "@src/store/avatar";
import { actors } from "@src/store/actor";
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
    result.push({
      color: color[key],
      spot: key,
    });
  }
  return result;
}

export function handleMintRequest(components: AvatarComponents, color: AvatarColors) {
  if (!get(user).loggedIn) {
    throw new Error("Not logged in");
  }
  if (get(avatar).tokenIdentifier) {
    console.log("Token Identifier :", get(avatar).tokenIdentifier);
    throw new Error("You already have an avatar");
  }
  const { avatarActor: avatarActor } = get(actors);
  if (!avatarActor) {
    throw new Error("No avatar actor");
  }
  mintRequest(components, color).then((result) => {
    console.log("Mint result :", result);
  });
}

async function mintRequest(components: AvatarComponents, color: AvatarColors): Promise<MintResult | Invoice> {
  const result = await get(actors).hubActor.mint(createMintRequest(components, color));
  console.log("Mint result :", result);
  if ("err" in result) {
    if ("Invoice" in result.err) {
      console.log("Invoice :", result.err.Invoice);
      return result.err.Invoice;
    }
  } else {
    console.log("Result :", result);
    return result;
  }
}
