<script>
  import { Router, Route } from "svelte-routing";
  import Home from "@src/pages/Home.svelte";
  import Faqs from "@src/pages/Faqs.svelte";
  import CreateAvatar from "@src/pages/CreateAvatar.svelte";
  import Random from "@src/pages/Random.svelte";
  import Legendary from "@src/pages/Legendary.svelte";
  import Accessories from "@src/pages/Accessories.svelte";
  import About from "@src/pages/About.svelte";
  import Partners from "@src/pages/Partners.svelte";
  import RandomWall from "@src/pages/RandomWall.svelte"
</script>

<Router>
  <Route path="create-avatar"><CreateAvatar /></Route>
  <Route path="/"><Home /></Route>
  <Route path="faqs"><Faqs /></Route>
  <Route path="legendary-avatars"><Legendary /></Route>
  <Route path="accessories"><Accessories /></Route>
  <Route path="about-us"><About /></Route>
  <Route path="partners"><Partners /></Route>
  <Route path="random"><Random /></Route>
  <Route path="random-wall"><RandomWall /></Route>
</Router>
