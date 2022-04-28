<script>
  import { Router, Route } from "svelte-routing";
  import Home from "./src/pages/Home.svelte";
  import CreateAvatar from "./src/pages/CreateAvatar.svelte";
</script>

<Router>
  <Route path="create-avatar"><CreateAvatar /></Route>
  <Route path="/"><Home /></Route>
</Router>

<style global lang="scss">
  @use "./src/styles/global.scss" as *;
</style>
