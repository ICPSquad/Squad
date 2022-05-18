<script lang="ts">
  import Carat from "@icons/Carat.svelte";
  import {
    categoriesExludingAccessories,
    categoriesIncludingAccessories,
    categoryDisplayName,
  } from "@src/utils/categories";

  export let includeAccessories: boolean = false;
  const categories = includeAccessories
    ? categoriesIncludingAccessories
    : categoriesExludingAccessories;

  export let categoryShowing: string;
  export let setCategoryShowing: (category: string) => void;
</script>

<div class="categories">
  {#each categories as category}
    <button
      on:click={() => setCategoryShowing(category)}
      class="category {categoryShowing == category ? 'selected' : ''}"
    >
      <div class="left">
        {categoryDisplayName[category]}
      </div>
      <Carat color={categoryShowing == category ? "#40b1f5" : "#E5E5E5"} />
    </button>
  {/each}
</div>

<style lang="scss">
  @use "./src/website/src/styles" as *;

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
