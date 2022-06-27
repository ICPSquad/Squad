<script>
  import { Router, Route } from "svelte-routing";
  import Home from "@src/pages/Home.svelte";
  import Faqs from "@src/pages/Faqs.svelte";
  import CreateAvatar from "@src/pages/CreateAvatar.svelte";
  import Legendary from "@src/pages/Legendary.svelte";
  import Accessories from "@src/pages/Accessories.svelte";
  import About from "@src/pages/About.svelte";
  import Partners from "@src/pages/Partners.svelte";
  import Mission from "@src/pages/Mission.svelte";
  import Contact from "@src/pages/Contact.svelte";
  import CreateAccessory from "@src/pages/CreateAccessory.svelte";
  import Leaderboard from "@src/pages/Leaderboard.svelte";
  import AddAccessory from "@src/pages/AddAccessory.svelte";
  import Profile from "@src/pages/Profile.svelte";
  import Roadmap from "@src/pages/Roadmap.svelte";
</script>

<Router>
  <Route path="create-avatar"><CreateAvatar /></Route>
  <Route path="create-accessory"><CreateAccessory /></Route>
  <Route path="/"><Home /></Route>
  <Route path="faqs"><Faqs /></Route>
  <Route path="legendary-avatars"><Legendary /></Route>
  <Route path="accessories"><Accessories /></Route>
  <Route path="about-us"><About /></Route>
  <Route path="partners"><Partners /></Route>
  <Route path="contact"><Contact /></Route>
  <Route path="mission"><Mission /></Route>
  <Route path="add-accessory"><AddAccessory /></Route>
  <Route path="leaderboard"><Leaderboard /></Route>
  <Route path="profile"><Profile /></Route>
  <Route path="roadmap"><Roadmap /></Route>
</Router>
