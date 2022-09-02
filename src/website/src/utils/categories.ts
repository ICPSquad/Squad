export const categoriesExludingAccessories = ["profile", "hairs", "eyes", "mouth", "ears", "nose", "clothes", "background"];

export const categoriesIncludingAccessories = [...categoriesExludingAccessories, "hat", "face", "glasses", "body", "misc"];

export const categoriesOnlyAccessories = ["hat", "face", "glasses", "body", "misc"];

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
  face: "Face ",
  glasses: "Glasses ",
  body: "Body",
  misc: "Misc",
};

export const categoryToColorPickers = {
  background: ["background"],
  profile: ["skin"],
  hairs: ["hairs", "eyebrows"],
  eyes: ["eyes", "eyeliner"],
  clothes: ["clothes"],
};

export const categoriesMission = ["general", "cronic", "icpunk", "education", "pending", "ended", "support"];
