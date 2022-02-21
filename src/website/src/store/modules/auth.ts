import { Actor } from "@dfinity/agent";
import { Principal } from "@dfinity/principal";
import { Commit } from "vuex";

import { Inventory } from "declarations/accessories/accessories.did.d";
import { AvatarPreviewNew, LayerId } from "@/declarations/avatar/avatar.did";
import { Slots } from "declarations/avatar/avatar.did";
import { addAccessoryLayers, removeAccessoryLayers } from "../../utils/svg_new";
import store from "..";

const state: {
  principal: Principal | null;
  wallet: "Plug" | "Stoic" | null;
  authenticatedActor_hub: Actor | null;
  authenticatedActor_nft: Actor | null;
  authenticatedActor_material: Actor | null;
  tokenIdentifier: string | null;
  rawAvatar: string | null;
  avatarInfo: AvatarPreviewNew | null;
  inventory: Inventory;
  hideClothing: boolean;
} = {
  principal: null,
  wallet: null,
  authenticatedActor_nft: null,
  authenticatedActor_hub: null,
  authenticatedActor_material: null,
  tokenIdentifier: null,
  rawAvatar: null,
  avatarInfo: null,
  inventory: [],
  hideClothing: false,
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
  setAvatarInfo(state: State, avatarInfo: AvatarPreviewNew) {
    state.avatarInfo = avatarInfo;
  },
  addAccessory(state: State, { slot, name }: { slot: string; name: string }) {
    state.avatarInfo!.slots[slot as keyof Slots] = [name];
    state.avatarInfo!.layers = addAccessoryLayers(state.avatarInfo!.layers, name);
    if (slot == "Body") {
      state.hideClothing = true;
    }
  },
  removeAccessory(state: State, { slot, name }: { slot: string; name: string }) {
    state.avatarInfo!.slots[slot as keyof Slots] = [];
    state.avatarInfo!.layers = removeAccessoryLayers(state.avatarInfo!.layers, name);
    if (slot == "Body") {
      state.hideClothing = false;
    }
  },
};

const getters = {
  getPrincipal: (state: State) => state.principal,
  getAuthenticatedActor_hub: (state: State) => state.authenticatedActor_hub,
  getAuthenticatedActor_nft: (state: State) => state.authenticatedActor_nft,
  getAuthenticatedActor_material: (state: State) => state.authenticatedActor_material,
  getInventory: (state: State) => state.inventory,
  getRawAvatar: (state: State) => state.rawAvatar,
  getWallet: (state: State) => state.wallet,
  getTokenAvatar: (state: State) => state.tokenIdentifier,
  isAvatarLoaded: (state: State) => state.rawAvatar !== null,
  isAvatarInfoLoaded: (state: State) => state.avatarInfo !== null,
  isInventoryConnected: (state: State) => state.authenticatedActor_material !== null,
  isConnected: (state: State) => state.authenticatedActor_hub !== null && state.authenticatedActor_nft, // TODO: is it really ok?
  isPrincipalSet: (state: State) => state.principal !== null,
  isAirdropConnected: (state: State) => state.authenticatedActor_hub !== null,
  isHubConnected: (state: State) => state.authenticatedActor_hub !== null,
  isRoomConnected: (state: State) => state.authenticatedActor_nft !== null && state.authenticatedActor_material,
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
  async loadTokenIdentifier({ commit, state }: { commit: Commit; state: State }) {
    const actor = state.authenticatedActor_nft;
    if (actor == null) {
      throw new Error("Need an authenticated actor to set token identifier");
    }
    //@ts-ignore
    const tokenIdentifier_result = await actor.myTokenIdentifier();
    commit("setTokenIdentifier", tokenIdentifier_result[0]);
    return;
  },

  async loadInfos({ dispatch, commit, state }: { dispatch: any; commit: Commit; state: State }) {
    const actor = state.authenticatedActor_nft;
    if (actor == null) {
      throw new Error("Need an authenticated actor");
    }

    //@ts-ignore
    const avatar_result = await actor.getAvatarInfos_new();
    console.log("avatar_result", avatar_result);
    if (avatar_result.err) {
      //TODO : avatar not found
      throw new Error(avatar_result.err);
    }
    let { token_identifier } = avatar_result.ok;
    console.log("token_identifier", token_identifier);
    store.commit("setAvatarInfo", avatar_result.ok);
  },
};

export default {
  state,
  mutations,
  getters,
  actions,
};
