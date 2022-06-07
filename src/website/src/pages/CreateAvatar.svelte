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
  import { categoriesOnlyAccessories, categoryDisplayName } from "@utils/categories";

  // Include accessories : (default is false, only include for testing purposes)
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
  let components: AvatarComponents = generateRandomAvatar(0, Math.random() > 0.5 ? filterOption.Man : filterOption.Woman);
  const updateAvatarComponent = (category: string, item: string) => {
    components[category] = item;
  };

  // Random reset function
  let randomlyResetAvatar = () => {
    components = generateRandomAvatar(0, Math.random() > 0.5 ? filterOption.Man : filterOption.Woman);
    colors = generateRandomColor();
  };

  let state: State = "creating-avatar";
  let setState = (newState: State) => {
    state = newState;
  };

  function handleSubmit() {
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
      <div class="categories">
        <Categories {includeAccessories} {categoryShowing} {setCategoryShowing} />
      </div>
      <div class="item-selection">
        <ItemSelection {colors} {updateAvatarColor} {updateAvatarComponent} {categoryShowing} {components} />
      </div>
    {:else}
      <Checkout {colors} {components} {state} {setState} />
    {/if}
    <div class="avatar-preview">
      <AvatarPreview {components} {randomlyResetAvatar} {colors} {handleSubmit} {state} />
    </div>
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

  @media (max-width: 960px) {
    .layout-grid {
      grid-template-columns: 3fr 3fr 4fr;
      grid-gap: 10px;
      grid-auto-flow: dense;
    }
    .categories {
      grid-column: span 2;
    }
    .item-selection {
      grid-column: span 2;
    }
    .avatar-preview {
      grid-row: span 2;
    }
  }
</style>
