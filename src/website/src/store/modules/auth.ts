import { Actor } from "@dfinity/agent";
import { Principal } from "@dfinity/principal";
import { Commit } from "vuex";

import { Inventory } from "declarations/materials/materials.did.d";
import { Slots } from "vue";

const state: {
  principal: Principal | null;
  wallet: "Plug" | "Stoic" | null;
  authenticatedActor_hub: Actor | null;
  authenticatedActor_nft: Actor | null;
  authenticatedActor_material: Actor | null;
  tokenIdentifier: string | null;
  rawAvatar: string | null;
  equipedAccessory: Slots | null;
  inventory: Inventory;
} = {
  principal: null,
  wallet: null,
  authenticatedActor_nft: null,
  authenticatedActor_hub: null,
  authenticatedActor_material: null,
  tokenIdentifier: null,
  rawAvatar: null,
  equipedAccessory: null,
  inventory: [],
};

type State = typeof state;

const mutations = {
  setPrincipal(state: State, principal: Principal) {
    state.principal = principal;
  },
  setAuthenticatedActor_hub(state: State, authenticatedActor: Actor) {
    state.authenticatedActor_hub = authenticatedActor;
  },
  setAuthenticatedActor_nft(state: State, authenticatedActor: Actor) {
    state.authenticatedActor_nft = authenticatedActor;
  },
  setAuthenticatedActor_material(state: State, authenticatedActor: Actor) {
    state.authenticatedActor_material = authenticatedActor;
  },
  setWallet(state: State, wallet: "Plug" | "Stoic") {
    state.wallet = wallet;
  },
  setInventory(state: State, inventory: Inventory) {
    state.inventory = inventory;
  },
  setTokenIdentifier(state: State, tokenIdentifier: string) {
    state.tokenIdentifier = tokenIdentifier;
  },
  setRawAvatar(state: State, rawAvatar: string) {
    state.rawAvatar = rawAvatar;
  },
  setEquipedAccessory(state: State, equipedAccessory: Slots) {
    state.equipedAccessory = equipedAccessory;
  },
};

const getters = {
  getPrincipal: (state: State) => state.principal,
  getAuthenticatedActor_hub: (state: State) => state.authenticatedActor_hub,
  getAuthenticatedActor_nft: (state: State) => state.authenticatedActor_nft,
  getAuthenticatedActor_material: (state: State) =>
    state.authenticatedActor_material,
  getInventory: (state: State) => state.inventory,
  getRawAvatar: (state: State) => state.rawAvatar,
  getEquipedAccessory: (state: State) => state.equipedAccessory,
  getWallet: (state: State) => state.wallet,
  getTokenAvatar: (state: State) => state.tokenIdentifier,
  isAvatarLoaded: (state: State) => state.rawAvatar !== null,
  isInventoryConnected: (state: State) =>
    state.authenticatedActor_material !== null,
  isConnected: (state: State) =>
    state.authenticatedActor_hub !== null && state.authenticatedActor_nft, // TODO: is it really ok?
  isPrincipalSet: (state: State) => state.principal !== null,
  isAirdropConnected: (state: State) => state.authenticatedActor_hub !== null,
  isHubConnected: (state: State) => state.authenticatedActor_hub !== null,
  isRoomConnected: (state: State) =>
    state.authenticatedActor_nft !== null && state.authenticatedActor_material,
  isTokenIdentifierFound: (state: State) => state.tokenIdentifier !== null,
};

const actions = {
  async loadInventory({ commit, state }: { commit: Commit; state: State }) {
    if (state.authenticatedActor_material !== null) {
      //@ts-ignore
      const inventory = await state.authenticatedActor_material.getInventory();
      commit("setInventory", inventory);
    }
  },
  async loadTokenIdentifier({
    commit,
    state,
  }: {
    commit: Commit;
    state: State;
  }) {
    const actor = state.authenticatedActor_nft;
    if (actor == null) {
      throw new Error("Need an authenticated actor to set token identifier");
    }
    //@ts-ignore
    const tokenIdentifier_result = await actor.myTokenIdentifier();
    commit("setTokenIdentifier", tokenIdentifier_result[0]);
    return;
  },
  async loadInfos({
    dispatch,
    commit,
    state,
  }: {
    dispatch;
    commit: Commit;
    state: State;
  }) {
    const actor = state.authenticatedActor_nft;
    if (actor == null) {
      throw new Error("Need an authenticated actor to set avatar");
    }

    //@ts-ignore
    const avatar_result = await actor.getAvatarInfos();
    console.log("avatar_result", avatar_result);
    if (avatar_result.err) {
      throw new Error(avatar_result.err);
      alert(avatar_result.err);
    }

    let token_identifier = avatar_result.ok.token_identifier;
    console.log("token_identifier", token_identifier);
    let raw_avatar = avatar_result.ok.avatar_svg;
    let slots = avatar_result.ok.slots;
    console.log("slots", slots);
    console.log("raw_avatar", raw_avatar);
    commit("setRawAvatar", raw_avatar);
    commit("setEquipedAccessory", slots);
    commit("setTokenIdentifier", token_identifier);
  },
};

export default {
  state,
  mutations,
  getters,
  actions,
};
