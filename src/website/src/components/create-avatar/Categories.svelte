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

  let listExpanded: boolean = false;

  const handleSetCategory = (category: string) => {
    listExpanded = false;
    setCategoryShowing(category);
  };
</script>

<div>
  <div class="categories desktop">
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
  <div class="categories mobile">
    <button on:click={() => (listExpanded = !listExpanded)} class="category">
      <div class="left">
        {categoryDisplayName[categoryShowing]}
      </div>
      <Carat rotate={listExpanded ? -90 : 90} color={"#E5E5E5"} />
    </button>
    {#if listExpanded}
      {#each categories as category}
        {#if categoryShowing !== category}
          <button
            on:click={() => handleSetCategory(category)}
            class="category {categoryShowing == category ? 'selected' : ''}"
          >
            <div class="left">
              {categoryDisplayName[category]}
            </div>
          </button>
        {/if}
      {/each}
    {/if}
  </div>
</div>

<style lang="scss">
  @use "./src/website/src/styles" as *;

  .categories.mobile {
    display: none;
  }

  button.category {
    background-color: $verydarkgrey;
    display: flex;
    justify-content: space-between;
    padding: 12px 40px;
    border-radius: 0;
    margin-bottom: 1px;
    width: 100%;
    &.selected {
      background-color: $darkgrey;
      color: $blue;
    }
  }

  @media (max-width: 960px) {
    button.category {
      padding: 12px 20px;
    }

    .categories.desktop {
      display: none;
    }

    .categories.mobile {
      display: block;
    }
  }
</style>
