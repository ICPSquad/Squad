<script lang="ts">
  import type { Recipe } from "@canisters/accessories/accessories.did.d";
  export let recipe: Recipe;

  $: recipeObject = recipeArrayToObject(recipe);

  function recipeArrayToObject(recipe: Recipe): any {
    let recipeObject = {};
    recipe.forEach((ingredient) => {
      recipeObject[ingredient] = recipeObject[ingredient] ? recipeObject[ingredient] + 1 : 1;
    });
    return recipeObject;
  }
</script>

{#if recipe.length > 0}
  <div class="recipe">
    <h3>Recipe</h3>
    <div class="ingredients">
      <div class="list">
        {#each Object.entries(recipeObject) as [ingredient, count]}
          <div class="count">
            <img src="assets/materials/{ingredient}.svg" alt="Ingredient" /> x{count}
          </div>
        {/each}
      </div>
    </div>
  </div>
{/if}

<style lang="scss">
  @use "./src/website/src/styles" as *;

  .recipe {
    background-color: $verydarkgrey;
    padding: 10px;
    margin: 10px auto;
    // min-height: 250px;
    // border: 2px solid $pink;
    border-radius: 10px;
  }

  h3 {
    color: var(--page-feature-color);
    text-align: center;
  }

  .list {
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
  }

  .count {
    display: flex;
    flex-direction: row;
    justify-content: center;
    align-items: center;
    font-weight: bold;
  }

  img {
    display: inline-flex;
    margin-right: 10px;
    height: 60px;
  }
</style>
