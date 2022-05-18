import App from "./App.svelte";
import "./src/styles/global.scss";

const app = new App({
  target: document.getElementById("root"),
});

console.log(process.env.NODE_ENV);

export default app;
