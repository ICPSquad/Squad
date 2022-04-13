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

  let categoryShowing = "Hairs";
  $: console.log(categoryShowing);
  $: console.log(categoryToItems[categoryShowing]);
  let items = [];
  $: if (categoryShowing && categoryToItems[categoryShowing]) {
    let newItems = [...categoryToItems[categoryShowing]];
    items = [...newItems];
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
      Eyeliner: [0, 169, 252, 1],
      Clothes: [0, 169, 252, 1],
    },
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
        <button on:click={() => (categoryShowing = category)} class="secondary">
          {category}
        </button>
      {/each}
    </div>
    <div class="items">
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
</style>
