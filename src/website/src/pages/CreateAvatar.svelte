<script>
  import Header from "../components/Header.svelte";
  import Footer from "../components/Footer.svelte";
  import { onMount } from "svelte";
  import { renderAvatar } from "../../src/utils/render";
  import AvatarComponentsSvg from "../components/AvatarComponentsSvg.svelte";
  import {
    backgrounds,
    ears,
    profiles,
    hairs,
    eyes,
    noses,
    mouths,
    clothes,
    accessories,
  } from "../../src/utils/list";
  import { categories, categoryToFolder } from "../../src/utils/categories";
  import Carat from "../icons/Carat.svelte";
  import ColorPicker from "../components/ColorPicker.svelte";

  const categoryToItems = {
    Background: backgrounds,
    Ears: ears,
    Profile: profiles,
    Hairs: hairs,
    Eyes: eyes,
    Nose: noses,
    Mouth: mouths,
    Clothes: clothes,
    Accessory: accessories,
  };

  const categoryToColorPickers = {
    Background: ["Background"],
    Profile: ["Skin"],
    Hairs: ["Hairs", "Eyebrows"],
    Eyes: ["Eyes", "Eyeliner"],
    Clothes: ["Clothes"],
  };

  let categoryShowing = "Eyes";
  let items = [];
  let colorPickers = [];
  $: if (categoryShowing && categoryToItems[categoryShowing]) {
    let newItems = [...categoryToItems[categoryShowing]];
    items = [...newItems];
    colorPickers = categoryToColorPickers[categoryShowing]
      ? categoryToColorPickers[categoryShowing]
      : [];
  }

  // $: items = categoryToItems[categoryShowing];

  let avatar = {
    Background: backgrounds[0],
    Profile: profiles[1],
    Ears: ears[2],
    Eyes: eyes[1],
    Nose: noses[0],
    Mouth: mouths[2],
    Hairs: hairs[10],
    Clothes: clothes[2],
    Accessory: accessories[1],
    Colors: {
      Skin: [255, 255, 0, 1],
      Hairs: [0, 169, 0, 1],
      Eyes: [0, 169, 252, 1],
      Eyebrows: [0, 169, 252, 1],
      Background: [0, 169, 252, 1],
      Eyeliner: [255, 0, 0, 1],
      Clothes: [0, 169, 252, 1],
    },
  };

  const updateAvatarColor = (componentName, col) => {
    let avatarNew = { ...avatar };
    avatarNew.Colors[componentName] = [col.r, col.g, col.b, 1];
    avatar = { ...avatarNew };
    renderUpdatedAvatar(avatarNew);
  };

  const updateAvatar = (category, item) => {
    let avatarNew = { ...avatar };
    avatarNew[category] = item;
    avatar = { ...avatarNew };
    renderUpdatedAvatar(avatarNew);
  };

  const renderUpdatedAvatar = (avatar) => {
    const avatarDiv = document.getElementById("avatar");
    renderAvatar(avatarDiv, avatar);
  };

  onMount(() => {
    renderUpdatedAvatar(avatar);
  });
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
            {category}
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
          selectedColorRGB={avatar.Colors[componentName]}
        />
      {/each}
      {#each items as item}
        <div
          on:click={() => updateAvatar(categoryShowing, item)}
          class="item {item == avatar[categoryShowing] ? 'selected' : ''}"
        >
          <img
            type="image/svg+xml"
            src="/assets/avatar-components/{categoryToFolder[
              categoryShowing
            ]}/{item.name}.svg"
            alt={item.name}
          />
        </div>
      {/each}
    </div>
    <div class="avatar">
      <div id="avatar" />
    </div>
  </div>
</main>
<Footer />
<div id="avatar-components">
  <AvatarComponentsSvg />
</div>

<style lang="scss">
  @use "./src/styles" as *;

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
</style>
