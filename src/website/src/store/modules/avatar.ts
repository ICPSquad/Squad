import { Avatar } from "../../types/avatar";
import { ComponentList } from "../../types/component";
import { Color } from "declarations/nft/nft.did.d";
import { backgrounds } from "../../utils/list";

const state: Avatar = {
  Background: backgrounds[0],
  Profile: null,
  Ears: null,
  Eyes: null,
  Nose: null,
  Mouth: null,
  Hairs: null,
  Clothes: null,
  Accessory: null,
  Colors: {
    Skin: [141, 85, 36, 1],
    Hairs: [154, 51, 0, 1],
    Eyes: [73, 118, 101, 1],
    Eyebrows: [154, 51, 0, 1],
    Background: [125, 122, 246, 100],
    Eyeliner: [207, 116, 160, 1],
    Clothes: [201, 100, 133, 1],
  },
};
type State = typeof state;

const mutations = {
  setProfile(state: State, profile: ComponentList) {
    state.Profile = profile;
  },
  setEars(state: State, ears: ComponentList) {
    state.Ears = ears;
  },
  setEyes(state: State, eyes: ComponentList) {
    state.Eyes = eyes;
  },
  setNose(state: State, nose: ComponentList) {
    state.Nose = nose;
  },
  setHairs(state: State, hairs: ComponentList) {
    state.Hairs = hairs;
  },
  setMouth(state: State, mouth: ComponentList) {
    state.Mouth = mouth;
  },
  setClothes(state: State, clothes: ComponentList) {
    state.Clothes = clothes;
  },
  setAccessory(state: State, accessory: ComponentList) {
    state.Accessory = accessory;
  },
  setSkinColor(state: State, rgb_color: [number, number, number]) {
    state.Colors.Skin[0] = rgb_color[0];
    state.Colors.Skin[1] = rgb_color[1];
    state.Colors.Skin[2] = rgb_color[2];
  },
  setClothesColor(state: State, rgb_color: [number, number, number]) {
    state.Colors.Clothes[0] = rgb_color[0];
    state.Colors.Clothes[1] = rgb_color[1];
    state.Colors.Clothes[2] = rgb_color[2];
  },
  setHairColor(state: State, rgb_color: [number, number, number]) {
    state.Colors.Hairs[0] = rgb_color[0];
    state.Colors.Hairs[1] = rgb_color[1];
    state.Colors.Hairs[2] = rgb_color[2];
  },
  setEyesColor(state: State, rgb_color: [number, number, number]) {
    state.Colors.Eyes[0] = rgb_color[0];
    state.Colors.Eyes[1] = rgb_color[1];
    state.Colors.Eyes[2] = rgb_color[2];
  },
  setEyebrowsColor(state: State, rgb_color: [number, number, number]) {
    state.Colors.Eyebrows[0] = rgb_color[0];
    state.Colors.Eyebrows[1] = rgb_color[1];
    state.Colors.Eyebrows[2] = rgb_color[2];
  },
  setBackgroundColor(state: State, rgb_color: [number, number, number]) {
    state.Colors.Background[0] = rgb_color[0];
    state.Colors.Background[1] = rgb_color[1];
    state.Colors.Background[2] = rgb_color[2];
  },
  setBackgroundOpacity(state: State, opacity: number) {
    state.Colors.Background[3] = Number(opacity);
  },
  setEyelinerColor(state: State, rgb_color: [number, number, number]) {
    state.Colors.Eyeliner[0] = rgb_color[0];
    state.Colors.Eyeliner[1] = rgb_color[1];
    state.Colors.Eyeliner[2] = rgb_color[2];
  },
};

const getters = {
  getAvatar(state: State) {
    return state;
  },
  getColors(state: State) {
    return state.Colors;
  },
  isSpecialHairs(state: State) {
    if (state.Hairs?.name === "Hair-4" || state.Hairs?.name === "Hair-6") {
      return true;
    } else {
      return false;
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
