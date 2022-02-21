import Vuex from "vuex";
import auth from "./modules/auth";
import avatar from "./modules/avatar";

export default new Vuex.Store({
  modules: {
    avatar,
    auth,
  },
});
