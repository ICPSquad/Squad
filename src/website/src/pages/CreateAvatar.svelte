<script lang="ts">
  import Header from "@src/components/shared/Header.svelte";
  import Footer from "@src/components/shared/Footer.svelte";
  import type { AvatarColors } from "../types/color.d";
  import type { AvatarComponents } from "../types/avatar.d";
  import { generateRandomAvatar, filterOption } from "@tasks/generate-avatar";
  import { generateRandomColor } from "@utils/color";
  import Categories from "@src/components/create-avatar/Categories.svelte";
  import ItemSelection from "@src/components/create-avatar/ItemSelection.svelte";
  import AvatarPreview from "@src/components/create-avatar/AvatarPreview.svelte";
  import Checkout from "@src/components/create-avatar/Checkout.svelte";
  import type { State } from "@src/components/create-avatar/types";

  // Include accessories?
  let includeAccessories = false;

  // Category showing
  let categoryShowing = "profile";
  const setCategoryShowing = (category: string) => {
    categoryShowing = category;
  };

  // Color management
  let colors: AvatarColors = generateRandomColor();
  const updateAvatarColor = (name: string, color: any) => {
    colors[name] = [color.r, color.g, color.b, 1];
  };

  // Avatar management
  let components: AvatarComponents = generateRandomAvatar(
    0,
    Math.random() > 0.5 ? filterOption.Man : filterOption.Woman
  );
  const updateAvatarComponent = (category: string, item: string) => {
    console.log("update", category, item);
    components[category] = item;
  };

  // Random reset function
  let randomlyResetAvatar = () => {
    components = generateRandomAvatar(
      0,
      Math.random() > 0.5 ? filterOption.Man : filterOption.Woman
    );
    colors = generateRandomColor();
  };

  // Interractions with canister. Not sure how to manage the followings : UI/Error handling... ?
  let state: State = "creating-avatar";
  let setState = (newState: State) => {
    state = newState;
  };

  async function handleSubmit() {
    state = "waiting-wallet-connection";
  }
</script>

<Header />
<div class="page-header">
  <h1>Create Avatar</h1>
</div>
<main class="container">
  <div class="layout-grid">
    {#if state === "creating-avatar"}
      <Categories {includeAccessories} {categoryShowing} {setCategoryShowing} />
      <ItemSelection
        {colors}
        {updateAvatarColor}
        {updateAvatarComponent}
        {categoryShowing}
        {components}
      />
    {:else}
      <Checkout {state} {setState} />
    {/if}
    <AvatarPreview
      {components}
      {randomlyResetAvatar}
      {colors}
      {handleSubmit}
      {state}
    />
  </div>
</main>
<Footer />

<style lang="scss">
  @use "./src/website/src/styles" as *;

  main {
    --page-feature-color: #{$pink};
  }
  .layout-grid {
    display: grid;
    grid-template-columns: 1fr 1fr 1fr;
    grid-gap: 40px;
  }
</style>
