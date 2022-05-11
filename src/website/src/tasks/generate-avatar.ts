import type { AvatarComponents } from "@src/types/avatar";
import { backgrounds, profiles, ears, mouths, hairs, eyes, noses, clothes, faceAccessories, bodyAccessories, miscAccessories, eyesAccessories, hatAccessories } from "@utils/list";

/*
  Generate a random avatar based on all the availables components in the list.
  @param probability_accessory: The probably of having an accessory in a slot. The probability is a number between 0 and 1 and is the same for all slots. Put 0 if you don't want accessories.
*/

export enum filterOption {
  Man,
  Woman,
  Any
}

// Create groups of styles that work well together
const filteredSets = {
  [filterOption.Man]: {
    profiles,
    hairs: [ hairs[0], hairs[1], hairs[4], ...hairs.slice(9,17) ],
    eyes: [ ...eyes.slice(0,4), ...eyes.slice(10) ],
    mouths: [ ...mouths.slice(0,5), ...mouths.slice(13) ],
    noses
  },
  [filterOption.Woman]: {
    profiles: [ ...profiles.slice(1) ],
    hairs: [ ...hairs.slice(1,3), ...hairs.slice(5,6), ...hairs.slice(8,9), hairs[11], hairs[15], hairs[17] ],
    eyes: [ ...eyes.slice(5,9) ],
    mouths: [ ...mouths.slice(2,3), ...mouths.slice(6,12) ],
    noses: [ ...noses.slice(1) ]
  },
  [filterOption.Any]: {
    profiles,
    hairs,
    eyes,
    mouths,
    noses
  }
}

export function generateRandomAvatar(probability_accessory: number, filter_option = filterOption.Any): AvatarComponents {
  if (probability_accessory > 1 || probability_accessory < 0) {
    throw new Error("probability_accessory must be between 0 and 1");
  }

  let avatar = {
    background: backgrounds[Math.floor(Math.random() * backgrounds.length)].name,
    profile: filteredSets[filter_option].profiles[Math.floor(Math.random() * filteredSets[filter_option].profiles.length)].name,
    ears: ears[Math.floor(Math.random() * ears.length)].name,
    mouth: filteredSets[filter_option].mouths[Math.floor(Math.random() * filteredSets[filter_option].mouths.length)].name,
    eyes: filteredSets[filter_option].eyes[Math.floor(Math.random() * filteredSets[filter_option].eyes.length)].name,
    nose: filteredSets[filter_option].noses[Math.floor(Math.random() * filteredSets[filter_option].noses.length)].name,
    hairs: filteredSets[filter_option].hairs[Math.floor(Math.random() * filteredSets[filter_option].hairs.length)].name,
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
