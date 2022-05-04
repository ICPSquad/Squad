export const categoriesExludingAccessories = [
  "profile",
  "hairs",
  "eyes",
  "mouth",
  "ears",
  "nose",
  "clothes",
  "background",
];

export const categoriesIncludingAccessories = [
  ...categoriesExludingAccessories,
  "hat",
  "face",
  "glasses",
  "body",
  "misc",
];

export const categoryDisplayName = {
  background: "Background",
  ears: "Ears",
  profile: "Profile & Skin",
  hairs: "Hair",
  eyes: "Eyes",
  nose: "Nose",
  mouth: "Mouth",
  clothes: "Clothes",
  hat: "Hat",
  face: "Face Accessories",
  glasses: "Glasses",
  body: "Body Accessories",
  misc: "Misc Accessories",
};

export const categoryToColorPickers = {
  background: ["background"],
  profile: ["skin"],
  hairs: ["hairs", "eyebrows"],
  eyes: ["eyes", "eyeliner"],
  clothes: ["clothes"],
};
