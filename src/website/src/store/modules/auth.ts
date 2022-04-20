import { Actor } from "@dfinity/agent";
import { Principal } from "@dfinity/principal";
import { Commit } from "vuex";

import store from "..";
import router from "../../router/router";

const state: {
  principal: Principal | null;
  wallet: "Plug" | "Stoic" | null;
  authenticatedActor_hub: Actor | null;
  authenticatedActor_nft: Actor | null;
  authenticatedActor_material: Actor | null;
  authenticatedActor_ledger: Actor | null;
  status: string;
  tokenIdentifier: string | null;
  rawAvatar: string | null;
  hideClothing: boolean;
} = {
  principal: null,
  wallet: null,
  authenticatedActor_nft: null,
  authenticatedActor_hub: null,
  authenticatedActor_material: null,
  authenticatedActor_ledger: null,
  status: "disconnected",
  tokenIdentifier: null,
  rawAvatar: null,
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
  setAuthenticatedActor_ledger(state: State, authenticatedActor: Actor) {
    state.authenticatedActor_ledger = authenticatedActor;
  },
  setStatus(state: State, status: string) {
    state.status = status;
  },
  setWallet(state: State, wallet: "Plug" | "Stoic") {
    state.wallet = wallet;
  },
  setTokenIdentifier(state: State, tokenIdentifier: string) {
    state.tokenIdentifier = tokenIdentifier;
  },
  setRawAvatar(state: State, rawAvatar: string) {
    state.rawAvatar = rawAvatar;
  },
};

const getters = {
  getPrincipal: (state: State) => state.principal,
  getAuthenticatedActor_hub: (state: State) => state.authenticatedActor_hub,
  getAuthenticatedActor_nft: (state: State) => state.authenticatedActor_nft,
  getAuthenticatedActor_material: (state: State) => state.authenticatedActor_material,
  getAuthenticatedActor_ledger: (state: State) => state.authenticatedActor_ledger,
  getStatus: (state: State) => state.status,
  getRawAvatar: (state: State) => state.rawAvatar,
  getWallet: (state: State) => state.wallet,
  getTokenAvatar: (state: State) => state.tokenIdentifier,
  isAvatarLoaded: (state: State) => state.rawAvatar !== null,
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
      alert("Error loading your infos: " + avatar_result.err);
      router.push("/");
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
