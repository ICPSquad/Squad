import { createApp, VueElement } from "vue";
import App from "./App.vue";
import router from "./router/router";
import store from "./store";
import { AuthClient } from "@dfinity/auth-client";
import "../assets/style.css";

const app = createApp(App);
app.use(router);
app.use(store);
app.mount("#app");

/**
 * @dfinity/agent requires this. Can be removed once it's fixed
 */
window.global = window;
AuthClient.create().then((v) => {
  //@ts-ignore
  window.authClient = v;
});
