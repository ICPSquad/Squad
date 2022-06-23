import App from "./App.svelte";
import { persistConnexion } from "@src/utils/connection";
import "./src/styles/global.scss";

const app = new App({
  target: document.getElementById("root"),
});

export default app;

persistConnexion();
