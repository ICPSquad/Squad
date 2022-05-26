<script lang="ts">
  import ColorPicker from "./ColorPicker.svelte";
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

  import { categoryToColorPickers } from "@utils/categories";
  import RenderComponent from "../render/RenderComponent.svelte";

  export let colors;
  export let updateAvatarColor;
  export let updateAvatarComponent;
  export let categoryShowing;
  export let components;

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

  // Color management
  let colorPickers = [];

  let items = [];
  $: items = categoryToItems[categoryShowing];

  $: if (categoryShowing && categoryToItems[categoryShowing]) {
    let newItems = [...categoryToItems[categoryShowing]];
    items = categoryShowing == "background" ? [] : [...newItems];
    colorPickers = categoryToColorPickers[categoryShowing]
      ? categoryToColorPickers[categoryShowing]
      : [];
  }
</script>

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
      class="item {item.name == components[categoryShowing] ? 'selected' : ''}"
    >
      <RenderComponent
        name={item.name}
        layers={item.layers}
        category={categoryShowing}
      />
    </div>
  {/each}
</div>

<style lang="scss">
  @use "./src/website/src/styles" as *;

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
    cursor: pointer;
    overflow: hidden;
    border: 3px solid transparent;
    &.selected {
      border-color: $green;
    }
  }

  @media (max-width: 960px) {
    .items {
      grid-template-columns: 1fr 1fr 1fr 1fr;
      grid-gap: 10px;
    }
  }

  @media (max-width: 600px) {
    .items {
      grid-template-columns: 1fr 1fr 1fr;
      grid-gap: 10px;
    }
  }
</style>
