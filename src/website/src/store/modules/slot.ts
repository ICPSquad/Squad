import { Slots, Accessory } from "../../types/accessories";

const state: Slots = {
  Hat: null,
  Face: null,
  Eyes: null,
  Body: null,
  Misc: null,
};

type State = typeof state;

const mutations = {
  setAccessory(state: State, accessory: Accessory | null) {
    if (accessory == null) {
      return;
    }
    accessory.slots.forEach((slot) => {
      state[slot] = accessory;
    });
  },
  clearSlot(state: State, slot: string) {
    state[slot] = null;
  },
};

const getters = {
  getSlots(state: State) {
    return state;
  },
  getHatId(state: State) {
    if (state.Hat == null) {
      return "#empty";
    } else {
      return `#${state.Hat.name}`;
    }
  },
  getEyesId(state: State) {
    if (state.Eyes == null) {
      return "#empty";
    } else {
      return `#${state.Eyes.name}`;
    }
  },
  getFaceId(state: State) {
    if (state.Face == null) {
      return "#empty";
    } else {
      return `#${state.Face.name}`;
    }
  },
  getBodyId(state: State) {
    if (state.Body == null) {
      return "#empty";
    } else {
      return `#${state.Body.name}`;
    }
  },
  getMiscId(state: State) {
    if (state.Misc == null) {
      return "#empty";
    } else {
      return `#${state.Misc.name}`;
    }
  },
};

const actions = {};

export default {
  state,
  mutations,
  getters,
  actions,
};
