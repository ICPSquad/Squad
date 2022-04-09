<script>
  import { Router, Route } from "svelte-routing";
  import Home from "./src/pages/Home.svelte";
  import About from "./src/pages/About.svelte";
</script>

<Router>
  <Route path="about"><About /></Route>
  <Route path="/"><Home /></Route>
</Router>

<style global lang="scss">
  @use "./src/styles/global.scss" as *;
</style>
