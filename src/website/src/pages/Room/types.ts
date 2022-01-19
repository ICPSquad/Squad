// List of types of accessories for the preview room
import store from "../../store";
import { Slots } from "../../types/accessories";

export type TypesAccessories = {
  name: string;
  slots: string[];
  message: string;
};

export const list_types_accessories: TypesAccessories[] = [
  {
    name: "Hat 🧢",
    slots: ["Hat"],
    message:
      "This is everything that you can wear on top of your head. Those accessories take only one slot : Hat.",
  },
  {
    name: "Glasses 👓",
    slots: ["Eyes"],
    message:
      "This is everything that you can wear on your eyes. Those accessories take only one slot : Eyes.",
  },
  {
    name: "Face 😶",
    slots: ["Face"],
    message:
      "This is everything that you can wear on your face. Those accessories take only one slot : Face.",
  },
  {
    name: "Clothes 🧥",
    slots: ["Body"],
    message:
      "This is everything that you can wear on your body. Those accessories take only one slot : Body.",
  },
  {
    name: "Special ✨",
    slots: ["Misc"],
    message:
      "This is the special slot, accessories that don't fit in any other categories end up here. Those accessories take only one slot : Special.",
  },
  {
    name: "Head 👱",
    slots: ["Face", "Eyes"],
    message:
      "Those accessories take two slots : Face and Eyes. You cannot wear glasses with those accessories.",
  },
  {
    name: "Masks 🎭",
    slots: ["Face", "Eyes", "Hat"],
    message:
      "Those accessories take three slots : Face, Eyes and Hat. You cannot wear glasses or hat with those accessories.",
  },
];

export function slotsEqual(slot_1: string[], slot_2: string[]) {
  if (slot_1.length !== slot_2.length) {
    return false;
  }
  for (let i = 0; i < slot_1.length; i++) {
    if (slot_1[i] !== slot_2[i]) {
      return false;
    }
  }
  return true;
}

function getLockedSlots(slots: Slots): string[] {
  const locked: string[] = [];
  for (const slot in slots) {
    if (slots[slot] != null) {
      locked.push(slot);
    }
  }
  return locked;
}

export function isTypeLocked(type: TypesAccessories): string | null {
  const slots = store.getters.getEquipedAccessory;
  const locked = getLockedSlots(slots);
  if (locked.length === 0) {
    return null;
  }

  for (let i = 0; i < locked.length; i++) {
    for (let j = 0; j < type.slots.length; j++) {
      if (locked[i] === type.slots[j]) {
        return locked[i];
      }
    }
  }

  return null;
}

export function isSlotLocked(slot: string): boolean {
  const locked = store.getters.getLocked;
  if (locked.length === 0) {
    return false;
  }

  for (let i = 0; i < locked.length; i++) {
    if (locked[i] === slot) {
      return true;
    }
  }

  return false;
}
