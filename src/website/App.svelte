<script>
  import { Router, Route } from "svelte-routing";
  import Home from "./src/pages/Home.svelte";
  import Faqs from "./src/pages/Faqs.svelte";
  import CreateAvatar from "./src/pages/CreateAvatar.svelte";
  import Random from "./src/pages/Random.svelte";
  // import Test from "./src/pages/Test.svelte";
</script>

<Router>
  <Route path="create-avatar"><CreateAvatar /></Route>
  <Route path="/"><Home /></Route>
  <Route path="random"><Random /></Route>
  <Route path="faqs"><Faqs /></Route>
</Router>

<style global lang="scss">
  @use "./src/styles/global.scss" as *;
</style>
