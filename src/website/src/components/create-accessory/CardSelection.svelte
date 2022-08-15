<script lang="ts">
  import { faceAccessories, hatAccessories, eyesAccessories, bodyAccessories, miscAccessories } from "@utils/list";

  export let categoryShowing;
  export let cardSelected;
  export let setCardSelected;

  const categoryToItems = {
    hat: hatAccessories,
    face: faceAccessories,
    glasses: eyesAccessories,
    body: bodyAccessories,
    misc: miscAccessories,
  };

  const categoryToFolder = {
    hat: "hat",
    face: "face",
    glasses: "eyes", // Sorry for that
    body: "body",
    misc: "misc",
  };

  let items = [];
  $: items = categoryToItems[categoryShowing];
</script>

<div class="items">
  {#each items as item}
    <div on:click={() => setCardSelected(item.name)} class="item {item.name == cardSelected ? 'selected' : ''}">
      <img src="/assets/accessories/{categoryToFolder[categoryShowing]}/{item.name}/{item.name}-minified.svg" alt="" />
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
    height: 180px;
    width: 180px;
    cursor: pointer;
    overflow: hidden;
    border: 3px solid transparent;
    &.selected {
      border-color: $green;
    }
  }

  @media (max-width: 960px) {
    .items {
      display: flex;
      flex-direction: row;
      flex-wrap: wrap;
      justify-content: center;
      align-items: center;
    }
  }

  @media (max-width: 600px) {
    .items {
      grid-template-columns: 1fr 1fr 1fr;
      grid-gap: 10px;
    }
  }
</style>
