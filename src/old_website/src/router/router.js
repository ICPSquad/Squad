import { createRouter, createWebHashHistory } from "vue-router";
import HomePage from "../pages/Home.vue";
import Privacy from "../pages/Privacy.vue";
import Lottery from "../pages/Lottery/Lottery.vue";
import Education from "../pages/Education/Education.vue";
import Accessory from "../pages/Accessory/AccessoryHome.vue";
import Airdrop from "../pages/Accessory/Airdrop.vue";

const routes = [
  { path: "/", component: HomePage },
  { path: "/privacy", component: Privacy },
  { path: "/accessory", component: Accessory },
  { path: "/airdrop", component: Airdrop },
  { path: "/lottery", component: Lottery },
  { path: "/education", component: Education },
  { path: "/avatar", component: () => import("../pages/Mint/AppMint.vue") },
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
    path: "/lab",
    component: () => import("../pages/Lab/AppLab.vue"),
  },
  {
    path: "/preorder",
    component: () => import("../pages/Preorder/Main.vue"),
  },
];

const router = createRouter({
  history: createWebHashHistory(),
  routes,
});

export default router;
