// List of components for the avatar minter
// This list is different from the actual list of components that is stored in the backend canister.
// Some component listed here can actually represent multiple layers.

import { Color } from "../../../declarations/avatar/avatar.did.d";
import { Accessory } from "../types/accessories";
import { ComponentList } from "../types/component";

export const backgrounds: ComponentList[] = [
  {
    name: "Background-base",
    components: [{ name: "Background-base", layer: 5 }],
  },
];

export const ears: ComponentList[] = [
  {
    name: "Business-ears",
    components: [{ name: "Business-ears", layer: 30 }],
  },
  {
    name: "Punk-ears",
    components: [{ name: "Punk-ears", layer: 30 }],
  },
  {
    name: "Miss-ears",
    components: [{ name: "Miss-ears", layer: 30 }],
  },
];

export const profiles: ComponentList[] = [
  {
    name: "Business-profile",
    components: [
      { name: "Business-body", layer: 20 },
      { name: "Business-head", layer: 35 },
    ],
  },
  {
    name: "Punk-profile",
    components: [
      { name: "Punk-body", layer: 20 },
      { name: "Punk-head", layer: 35 },
    ],
  },
  {
    name: "Miss-profile",
    components: [
      { name: "Miss-body", layer: 20 },
      { name: "Miss-head", layer: 35 },
    ],
  },
];

export const hairs: ComponentList[] = [
  {
    name: "Hair-1",
    components: [{ name: "Hair-1", layer: 75 }],
  },
  {
    name: "Hair-1-base",
    components: [{ name: "Hair-1-base", layer: 75 }],
  },
  {
    name: "Hair-2",
    components: [
      { name: "Hair-2", layer: 75 },
      { name: "Hair-2-back", layer: 10 },
    ],
  },
  {
    name: "Hair-2-base",
    components: [
      { name: "Hair-2-base", layer: 75 },
      { name: "Hair-2-back", layer: 10 },
    ],
  },
  {
    name: "Hair-3",
    components: [{ name: "Hair-3", layer: 75 }],
  },

  {
    name: "Hair-5",
    components: [
      { name: "Hair-5", layer: 75 },
      { name: "Hair-5-back", layer: 10 },
    ],
  },

  {
    name: "Hair-7",
    components: [
      { name: "Hair-7", layer: 75 },
      { name: "Hair-7-back", layer: 10 },
    ],
  },
  {
    name: "Hair-8",
    components: [
      { name: "Hair-8", layer: 75 },
      { name: "Hair-8-back", layer: 10 },
    ],
  },
  {
    name: "Hair-9",
    components: [
      { name: "Hair-9", layer: 75 },
      { name: "Hair-9-back", layer: 10 },
    ],
  },
  {
    name: "Hair-10",
    components: [{ name: "Hair-10", layer: 75 }],
  },
  {
    name: "Hair-11",
    components: [{ name: "Hair-11", layer: 75 }],
  },
  {
    name: "Hair-12",
    components: [{ name: "Hair-12", layer: 75 }],
  },
  {
    name: "Hair-13",
    components: [
      { name: "Hair-13", layer: 75 },
      { name: "Hair-13-back", layer: 10 },
      { name: "Hair-13-top", layer: 90 },
    ],
  },
  {
    name: "Hair-14",
    components: [{ name: "Hair-14", layer: 75 }],
  },
  {
    name: "Hair-15",
    components: [{ name: "Hair-15", layer: 75 }],
  },
  {
    name: "Hair-6-base",
    components: [
      { name: "Hair-6-base", layer: 75 },
      { name: "Hair-6-base-back", layer: 10 },
    ],
  },
  {
    name: "Hair-6",
    components: [
      { name: "Hair-6", layer: 75 },
      { name: "Hair-6-back", layer: 10 },
    ],
  },
  {
    name: "Hair-4",
    components: [
      { name: "Hair-4", layer: 75 },
      { name: "Hair-4-back", layer: 10 },
    ],
  },
];
export const eyes = [
  {
    name: "Business-angry-eyes",
    components: [{ name: "Business-angry-eyes", layer: 50 }],
  },
  {
    name: "Business-confused-eyes",
    components: [{ name: "Business-confused-eyes", layer: 50 }],
  },
  {
    name: "Business-scheming-eyes",
    components: [{ name: "Business-scheming-eyes", layer: 50 }],
  },
  {
    name: "Business-tired-eyes",
    components: [{ name: "Business-tired-eyes", layer: 50 }],
  },
  {
    name: "Business-uninterested-eyes",
    components: [{ name: "Business-uninterested-eyes", layer: 50 }],
  },
  {
    name: "Miss-annoyed-eyes",
    components: [{ name: "Miss-annoyed-eyes", layer: 50 }],
  },
  {
    name: "Miss-confident-eyes",
    components: [{ name: "Miss-confident-eyes", layer: 50 }],
  },
  {
    name: "Miss-disgusted-eyes",
    components: [{ name: "Miss-disgusted-eyes", layer: 50 }],
  },
  {
    name: "Miss-scheming-eyes",
    components: [{ name: "Miss-scheming-eyes", layer: 50 }],
  },
  {
    name: "Miss-surprised-eyes",
    components: [{ name: "Miss-surprised-eyes", layer: 50 }],
  },
  {
    name: "Punk-annoyed-eyes",
    components: [{ name: "Punk-annoyed-eyes", layer: 50 }],
  },
  {
    name: "Punk-confident-eyes",
    components: [{ name: "Punk-confident-eyes", layer: 50 }],
  },
  {
    name: "Punk-crying-eyes",
    components: [{ name: "Punk-crying-eyes", layer: 50 }],
  },
  {
    name: "Punk-disgusted-eyes",
    components: [{ name: "Punk-disgusted-eyes", layer: 50 }],
  },
  {
    name: "Punk-embarassed-eyes",
    components: [{ name: "Punk-embarassed-eyes", layer: 50 }],
  },
];

export const noses = [
  {
    name: "Business-nose",
    components: [{ name: "Business-nose", layer: 55 }],
  },
  {
    name: "Punk-nose",
    components: [{ name: "Punk-nose", layer: 55 }],
  },
  {
    name: "Miss-nose",
    components: [{ name: "Miss-nose", layer: 55 }],
  },
];

export const clothes: ComponentList[] = [
  {
    name: "1",
    components: [{ name: "1", layer: 70 }],
  },
  {
    name: "2",
    components: [{ name: "2", layer: 70 }],
  },
  {
    name: "3",
    components: [{ name: "3", layer: 70 }],
  },
  {
    name: "4",
    components: [{ name: "4", layer: 70 }],
  },
];

export const mouths = [
  {
    name: "Business-angry-mouth",
    components: [{ name: "Business-angry-mouth", layer: 45 }],
  },
  {
    name: "Business-confused-mouth",
    components: [{ name: "Business-confused-mouth", layer: 45 }],
  },

  {
    name: "Business-scheming-mouth",
    components: [{ name: "Business-scheming-mouth", layer: 45 }],
  },
  {
    name: "Business-tired-mouth",
    components: [{ name: "Business-tired-mouth", layer: 45 }],
  },
  {
    name: "Business-uninterested-mouth",
    components: [{ name: "Business-uninterested-mouth", layer: 45 }],
  },
  // {
  //   name: "Miss-annoyed-mouth",
  //   components: [{ name: "Miss-annoyed-mouth", layer: 45 }],
  // },
  {
    name: "Miss-confident-mouth",
    components: [{ name: "Miss-confident-mouth", layer: 45 }],
  },
  {
    name: "Miss-disgusted-mouth",
    components: [{ name: "Miss-disgusted-mouth", layer: 45 }],
  },
  {
    name: "Miss-scheming-mouth",
    components: [{ name: "Miss-scheming-mouth", layer: 45 }],
  },
  {
    name: "Miss-surprised-mouth",
    components: [{ name: "Miss-surprised-mouth", layer: 45 }],
  },
  {
    name: "Punk-annoyed-mouth",
    components: [{ name: "Punk-annoyed-mouth", layer: 45 }],
  },
  {
    name: "Punk-confident-mouth",
    components: [{ name: "Punk-confident-mouth", layer: 45 }],
  },
  {
    name: "Punk-crying-mouth",
    components: [{ name: "Punk-crying-mouth", layer: 45 }],
  },
  {
    name: "Punk-disgusted-mouth",
    components: [{ name: "Punk-disgusted-mouth", layer: 45 }],
  },
  {
    name: "Punk-embarassed-mouth",
    components: [{ name: "Punk-embarassed-mouth", layer: 45 }],
  },
];

export const frontend_layers = [
  { title: "Background 🌈", components: backgrounds },
  { title: "Profile 👤", components: profiles },
  { title: "Ears 👂", components: ears },
  { title: "Eyes 👀", components: eyes },
  { title: "Nose 👃", components: noses },
  { title: "Mouth 👄", components: mouths },
  { title: "Hairs 💇", components: hairs },
  { title: "Clothes 👔", components: clothes },
  { title: "Mint ⛏", components: [] },
];

// Indicates where the color picker must be available
export const color_picker_layers = [
  "Profile 👤",
  "Eyes 👀",
  "Clothes 👔",
  "Hairs 💇",
  "Background 🌈",
];

export const opacity_selector_layers = ["Background 🌈"];

// Initial selection for the skin colors
export const colors_skin: Color[] = [
  [141, 85, 36, 1],
  [198, 134, 66, 1],
  [224, 172, 105, 1],
  [241, 194, 125, 1],
  [255, 219, 172, 1],
];

export const colors_clothes: Color[] = [
  [0, 0, 0, 1],
  [223, 83, 107, 1],
  [97, 208, 79, 1],
  [34, 151, 230, 1],
  [40, 226, 229, 1],
  [205, 11, 188, 1],
  [245, 199, 16, 1],
  [158, 158, 158, 1],
];

export const colors_eyes: Color[] = [
  [99, 78, 52, 1],
  [46, 83, 111, 1],
  [61, 103, 29, 1],
  [28, 120, 71, 1],
  [73, 118, 101, 1],
];

export const colors_hair: Color[] = [
  [170, 136, 103, 1],
  [222, 190, 153, 1],
  [36, 28, 17, 1],
  [79, 26, 0, 1],
  [154, 51, 0, 1],
];

export const colors_background: Color[] = [
  [206, 31, 53, 1],
  [22, 221, 53, 1],
  [0, 169, 252, 1],
  [125, 122, 246, 1],
  [100, 50, 0, 1],
  [20, 70, 60, 1],
  [0, 25, 100, 1],
  [90, 0, 100, 1],
  [230, 230, 230, 1],
];

export const colors_eyeliner: Color[] = [
  [241, 171, 20, 1],
  [207, 116, 160, 1],
  [200, 255, 255, 1],
  [94, 70, 20, 1],
  [44, 76, 75, 1],
];

export const accessories: Accessory[] = [
  // Accessory that fill the 'Body' slot ->  Layer selected as 95
  {
    name: "Assassin-cap",
    slot: "Body",
    recipe: ["Cloth", "Cloth", "Cloth", "Glass", "Glass", "Metal"],
    description: "A black suit.",
    components: [{ name: "Assassin-cap", layer: 95 }],
  },
  {
    name: "Astro-suit",
    slot: "Body",
    recipe: [
      "Cloth",
      "Metal",
      "Circuit",
      "Circuit",
      "Circuit",
      "Dfinity-stone",
    ],
    description: "A suit of spacey technology.",
    components: [{ name: "Astro-body", layer: 95 }],
  },
  {
    name: "Cronic-tshirt",
    slot: "Body",
    recipe: [
      "Cloth",
      "Cloth",
      "Wood",
      "Wood",
      "Dfinity-stone",
      "Cronic-essence",
    ],
    description: "This tshirt reminds me of something...",
    components: [{ name: "Cronic-tshirt", layer: 95 }],
  },
  {
    name: "Devil-jacket",
    slot: "Body",
    recipe: ["Cloth", "Wood", "Wood", "Glass", "Metal", "Metal"],
    description: "A suit that scares the devil.",
    components: [{ name: "Devil-jacket", layer: 95 }],
  },
  {
    name: "Helicap-tshirt",
    slot: "Body",
    recipe: ["Cloth", "Cloth", "Cloth", "Wood", "Wood", "Metal"],
    description: "A simple helicap t-shirt.",
    components: [{ name: "Helicap-tshirt", layer: 95 }],
  },
  {
    name: "Lab-coat",
    slot: "Body",
    recipe: ["Wood", "Glass", "Glass", "Metal", "Circuit", "Circuit"],
    description: "A lab coat used to test new technologies.",
    components: [{ name: "Lab-coat", layer: 95 }],
  },
  {
    name: "Magic-cap",
    slot: "Body",
    recipe: ["Cloth", "Wood", "Wood", "Metal", "Metal", "Dfinity-stone"],
    description: "A suit of dark magic.",
    components: [{ name: "Magic-cap", layer: 95 }],
  },
  {
    name: "Shinobi-suit",
    slot: "Body",
    recipe: ["Cloth", "Wood", "Wood", "Wood", "Metal", "Metal"],
    description: "A shinobi jacket.",
    components: [{ name: "Shinobi-jacket", layer: 95 }],
  },
  // {
  //   name: "Squid-suit",
  //   slot: "Body",
  //   recipe: ["Cloth", "Cloth", "Wood", "Wood", "Glass", "Glass"],
  //   description: "todo",
  //   components: [{ name: "Squid-suit", layer: 95 }],
  // },
  {
    name: "Street-jacket",
    slot: "Body",
    recipe: ["Cloth", "Wood", "Glass", "Metal", "Circuit", "Dfinity-stone"],
    description: "A simple suit for a dystopian world.",
    components: [{ name: "Street-jacket", layer: 95 }],
  },
  {
    name: "Super-suit",
    slot: "Body",
    recipe: ["Cloth", "Wood", "Glass", "Metal", "Circuit", "Dfinity-stone"],
    description: "A suit of superpowers.",
    components: [{ name: "Super-suit", layer: 95 }],
  },
  {
    name: "Yakuza-suit",
    slot: "Body",
    recipe: ["Wood", "Wood", "Wood", "Metal", "Metal", "Metal"],
    description: "Used by the yakuza oni group to show their power.",
    components: [{ name: "Yakuza-suit", layer: 95 }],
  },

  // Accessory that fill the 'Hat' slot ->  Layer selected as 85 (so hair-top can go on top of it but not hair-middle)
  {
    name: "Assassin-hat",
    slot: "Hat",
    recipe: ["Cloth", "Wood", "Wood", "Metal"],
    description: "A hat used to hide the identity of the assassin.",
    components: [{ name: "Assassin-hat", layer: 85 }],
  },
  {
    name: "Astro-helmet",
    slot: "Hat",
    recipe: ["Metal", "Circuit", "Circuit", "Dfinity-stone"],
    description: "A helmet used to protect against radiation.",
    components: [{ name: "Astro-helmet", layer: 85 }],
  },
  {
    name: "Dark-magic-hood",
    slot: "Hat",
    recipe: ["Wood", "Wood", "Glass", "Dfinity-stone"],
    description: "A hood used to practice dark magic.",
    components: [{ name: "Dark-magic-hood", layer: 85 }],
  },
  {
    name: "Helicap",
    slot: "Hat",
    recipe: ["Cloth", "Cloth", "Wood", "Glass"],
    description: "Look mom, I can fly!",
    components: [{ name: "Helicap", layer: 85 }],
  },
  {
    name: "Marshall-hat",
    slot: "Hat",
    recipe: ["Metal", "Metal", "Metal"],
    description: "This hat gives you authority over this district. 👮",
    components: [{ name: "Marshall-hat", layer: 85 }],
  },
  {
    name: "Ninja-headband",
    slot: "Hat",
    recipe: ["Metal", "Metal", "Metal"],
    description: "I don't quit, I don't run, I never go back on my word. 🦊",
    components: [{ name: "Ninja-headband", layer: 85 }],
  },
  {
    name: "Santa-hat",
    slot: "Hat",
    recipe: ["Cloth", "Wood", "Cloth"],
    description: "Merry christmas! 🎅",
    components: [{ name: "Santa-hat", layer: 85 }],
  },
  {
    name: "Shinobi-strawhat",
    slot: "Hat",
    recipe: ["Cloth", "Wood", "Wood", "Wood"],
    description: "A straw hat used by the shinobi.",
    components: [{ name: "Shinobi-strawhat", layer: 85 }],
  },
  // Accessory that fill the 'Eyes' slot ->  Layer selected as 80
  {
    name: "Dfinity-eyemask",
    slot: "Eyes",
    recipe: ["Dfinity-stone", "Glass", "Glass"],
    description: "You can litterally see infinity... ∞",
    components: [{ name: "Dfinity-eyemask", layer: 80 }],
  },
  {
    name: "Lab-glasses",
    slot: "Eyes",
    recipe: ["Glass", "Glass", "Glass", "Circuit"],
    description: "A perfect pair of glasses for entering the lab.",
    components: [{ name: "Lab-glasses", layer: 80 }],
  },
  {
    name: "Matrix-glasses",
    slot: "Eyes",
    recipe: ["Metal", "Metal", "Metal"],
    description: "You can finally see through bullshit.",
    components: [{ name: "Matrix-glasses", layer: 80 }],
  },
  {
    name: "Monocle",
    slot: "Eyes",
    recipe: ["Metal", "Metal", "Metal"],
    description: "I'm wearing a monocle so I must be rich and famous.",
    components: [{ name: "Monocle", layer: 80 }],
  },
  // {
  //   name: "Punk-glasses",
  //   slot: "Eyes",
  //  recipe: ["Glass", "Glass", "Metal", "Punk-essence"],
  //   description: "A pair of glasses that gives you a punk look.",
  //   components: [{ name: "Punk-glasses", layer: 80 }],
  // },
  // Accessory that fill the 'Face' slot ->  Layer selected as 80
  {
    name: "Dfinity-face-mask",
    slot: "Face",
    recipe: ["Dfinity-stone", "Cloth", "Cloth"],
    description:
      "Facemask protecting you from any virus of the cyberspace... or maybe not.",
    components: [{ name: "Dfinity-face-mask", layer: 80 }],
  },
  {
    name: "Oni-half-mask",
    slot: "Face",
    recipe: ["Metal", "Metal", "Metal"],
    description: "A terrifying aura emanates from this mask.",
    components: [{ name: "Oni-half-mask", layer: 80 }],
  },
  // {
  //   name: "Punk-face-mask",
  //   slot: "Face",
  //  recipe: ["Cloth", "Cloth", "Punk-essence"],
  //   description: "A mask that gives you a punk look.",
  //   components: [{ name: "Punk-face-mask", layer: 80 }],
  // },
];

export function nameToSlot(name: string): string | undefined {
  return accessories.find((a) => a.name === name)?.slot;
}

export function nameToLayerId(name: string): number | undefined {
  return accessories.find((a) => a.name === name)?.components[0].layer;
}

export function nameToAccessory(name: string): Accessory | undefined {
  return accessories.find((a) => a.name === name);
}
