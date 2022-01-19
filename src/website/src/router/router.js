import { createRouter, createWebHashHistory } from "vue-router";
import HomePage from "../pages/Home.vue";
import Privacy from "../pages/Privacy.vue";
import Lottery from "../pages/Lottery/Lottery.vue";
import Education from "../pages/Education/Education.vue";
import HomeMint from "../pages/Mint/AppHomeCenter.vue";
import Loading from "../animations/Loading.vue";
import Accessory from "../pages/Accessory/AccessoryHome.vue";
import Airdrop from "../pages/Accessory/Airdrop.vue";
import Preorder from "../pages/Preorder.vue";

const routes = [
  { path: "/", component: HomePage },
  { path: "/preorder", component: Preorder },
  { path: "/privacy", component: Privacy },
  {
    path: "/accessory",
    component: Accessory,
  },
  { path: "/avatar", component: () => import("../pages/Mint/AppMint.vue") },
  { path: "/airdrop", component: Airdrop },
  { path: "/lottery", component: Lottery },
  { path: "/education", component: Education },
  { path: "/test", component: HomeMint },
  {
    path: "/minter",
    component: () => import("../pages/Mint/AppHomeMinter.vue"),
  },
  {
    path: "/center",
    component: () => import("../pages/Mint/AppHomeCenter.vue"),
  },
  {
    path: "/room",
    component: () => import("../pages/Room/Preview.vue"),
  },
  {
    path: "/loading",
    component: Loading,
  },
];

const router = createRouter({
  history: createWebHashHistory(),
  routes,
});

export default router;
