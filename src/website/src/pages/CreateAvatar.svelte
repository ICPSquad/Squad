<script lang="ts">
  import Carat from "@icons/Carat.svelte";
  import Shuffle from "@icons/Shuffle.svelte";
  import AvatarComponentsSvg from "@components/AvatarComponentsSvg.svelte";
  import Header from "@src/components/shared/Header.svelte";
  import Footer from "@src/components/shared/Footer.svelte";
  import RenderAvatar from "@components/render/RenderAvatar.svelte";
  import RenderComponent from "@components/render/RenderComponent.svelte";
  import ColorPicker from "@src/components/create-avatar/ColorPicker.svelte";
  import type { AvatarColors } from "../types/color.d";
  import type { AvatarComponents } from "../types/avatar.d";
  import { generateRandomAvatar } from "@tasks/generate-avatar";
  import { generateRandomColor } from "@utils/color";
  import {
    backgrounds,
    profiles,
    ears,
    mouths,
    eyes,
    noses,
    hairs,
    clothes,
  } from "@utils/list";
  import {
    faceAccessories,
    hatAccessories,
    eyesAccessories,
    bodyAccessories,
    miscAccessories,
  } from "@utils/list";
  import {
    categoriesExludingAccessories,
    categoriesIncludingAccessories,
    categoryDisplayName,
    categoryToColorPickers,
  } from "@utils/categories";

  const categoryToItems = {
    background: backgrounds,
    ears: ears,
    profile: profiles,
    hairs: hairs,
    eyes: eyes,
    nose: noses,
    mouth: mouths,
    clothes: clothes,
    hat: hatAccessories,
    face: faceAccessories,
    glasses: eyesAccessories,
    body: bodyAccessories,
    misc: miscAccessories,
  };

  // Toggle this to include/exclude accessories
  const includeAccessories = true;
  const categories = includeAccessories
    ? categoriesIncludingAccessories
    : categoriesExludingAccessories;

  let categoryShowing = "profile";
  let items = [];
  $: items = categoryToItems[categoryShowing];

  // Color management
  let colorPickers = [];
  $: if (categoryShowing && categoryToItems[categoryShowing]) {
    let newItems = [...categoryToItems[categoryShowing]];
    items = categoryShowing == "background" ? [] : [...newItems];
    colorPickers = categoryToColorPickers[categoryShowing]
      ? categoryToColorPickers[categoryShowing]
      : [];
    console.log("picker", colorPickers);
  }

  let colors: AvatarColors = generateRandomColor();
  const updateAvatarColor = (name: string, color: any) => {
    colors[name] = [color.r, color.g, color.b, 1];
  };

  // Avatar management
  let components: AvatarComponents = generateRandomAvatar(0);
  const updateAvatarComponent = (category: string, item: string) => {
    console.log("update", category, item);
    components[category] = item;
  };

  let randomlyResetAvatar = () => {
    components = generateRandomAvatar(0);
    colors = generateRandomColor();
  };
</script>

<Header />
<div class="page-header">
  <h1>Create Avatar</h1>
</div>
<main class="container">
  <div class="layout-grid">
    <div class="categories">
      {#each categories as category}
        <button
          on:click={() => (categoryShowing = category)}
          class="category {categoryShowing == category ? 'selected' : ''}"
        >
          <div class="left">
            {categoryDisplayName[category]}
          </div>
          <Carat color={categoryShowing == category ? "#40b1f5" : "#E5E5E5"} />
        </button>
      {/each}
    </div>
    <div class="items">
      {#each colorPickers as componentName}
        <ColorPicker
          {updateAvatarColor}
          {componentName}
          selectedColorRGB={colors[componentName]}
        />
      {/each}
      {#each items as item}
        <div
          on:click={() => updateAvatarComponent(categoryShowing, item.name)}
          class="item {item == components[categoryShowing] ? 'selected' : ''}"
        >
          <RenderComponent name={item.name} layers={item.layers} />
        </div>
      {/each}
    </div>
    <div class="avatar">
      <RenderAvatar avatarComponents={components} avatarColors={colors} />
      <button class="secondary shuffle" on:click={randomlyResetAvatar}>
        <div class="shuffle-icon">
          <Shuffle />
        </div>
        Random Reset
      </button>
    </div>
  </div>
</main>
<Footer />
<div id="avatar-components">
  <AvatarComponentsSvg />
</div>

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
  .items {
    display: grid;
    grid-template-columns: 1fr 1fr 1fr;
    grid-gap: 20px;
    grid-auto-rows: minmax(min-content, max-content);
  }
  .item {
    background-color: $darkgrey;
    border-radius: 10px;
    max-height: 125px;
    overflow: hidden;
    border: 3px solid transparent;
    &.selected {
      border-color: $green;
    }
  }
  #avatar-components {
    width: 0;
    height: 0;
  }
  button.category {
    background-color: $verydarkgrey;
    display: flex;
    justify-content: space-between;
    padding: 12px 40px;
    border-radius: 0;
    margin-bottom: 1px;
    &.selected {
      background-color: $darkgrey;
      color: $blue;
    }
  }
  button.shuffle {
    margin-top: 20px;
    line-height: 90%;
    .shuffle-icon {
      margin-right: 20px;
      padding-top: 2px;
    }
  }
</style>
