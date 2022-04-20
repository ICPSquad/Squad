import { createRouter, createWebHashHistory } from "vue-router";
import HomePage from "../pages/Home.vue";
import Privacy from "../pages/Privacy.vue";

const routes = [
  { path: "/", component: HomePage },
  { path: "/privacy", component: Privacy },
];

const router = createRouter({
  history: createWebHashHistory(),
  routes,
});

export default router;
