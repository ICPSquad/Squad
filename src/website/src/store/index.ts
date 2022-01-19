import Vuex from "vuex";
import auth from "./modules/auth";
import avatar from "./modules/avatar";
import slot from "./modules/slot";

export default new Vuex.Store({
  modules: {
    avatar,
    auth,
    slot,
  },
});
