import type { AvatarComponents } from "@src/types/avatar";
import { backgrounds, profiles, ears, mouths, hairs, eyes, noses, clothes, faceAccessories, bodyAccessories, miscAccessories, eyesAccessories, hatAccessories } from "@utils/list";

/* 
  Generate a random avatar based on all the availables components in the list. 
  @param probability_accessory: The probably of having an accessory in a slot. The probability is a number between 0 and 1 and is the same for all slots. Put 0 if you don't want accessories.
*/
export function generateRandomAvatar(probability_accessory: number): AvatarComponents {
  if (probability_accessory > 1 || probability_accessory < 0) {
    throw new Error("probability_accessory must be between 0 and 1");
  }
  let avatar = {
    background: backgrounds[Math.floor(Math.random() * backgrounds.length)].name,
    profile: profiles[Math.floor(Math.random() * profiles.length)].name,
    ears: ears[Math.floor(Math.random() * ears.length)].name,
    mouth: mouths[Math.floor(Math.random() * mouths.length)].name,
    eyes: eyes[Math.floor(Math.random() * eyes.length)].name,
    nose: noses[Math.floor(Math.random() * noses.length)].name,
    hairs: hairs[Math.floor(Math.random() * hairs.length)].name,
    clothes: clothes[Math.floor(Math.random() * clothes.length)].name,
    hat: Math.random() >= 1 - probability_accessory ? hatAccessories[Math.floor(Math.random() * hatAccessories.length)].name : undefined,
    glasses: Math.random() >= 1 - probability_accessory ? eyesAccessories[Math.floor(Math.random() * eyesAccessories.length)].name : undefined,
    face: Math.random() >= 1 - probability_accessory ? faceAccessories[Math.floor(Math.random() * faceAccessories.length)].name : undefined,
    body: Math.random() >= 1 - probability_accessory ? bodyAccessories[Math.floor(Math.random() * bodyAccessories.length)].name : undefined,
    misc: Math.random() >= 1 - probability_accessory ? miscAccessories[Math.floor(Math.random() * miscAccessories.length)].name : undefined,
  };
  return avatar;
}

function generateRandomBool(proba: number): boolean {
  return Math.random() >= 0.5;
}
