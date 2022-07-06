<script lang="ts">
  import { Link } from "svelte-routing";

  export let missing_materials: string[];

  $: missingObject = missingArrayToObject(missing_materials);

  function missingArrayToObject(missing: string[]): any {
    let missingObject = {};
    missing.forEach((ingredient) => {
      missingObject[ingredient] = missingObject[ingredient] ? missingObject[ingredient] + 1 : 1;
    });
    return missingObject;
  }
</script>

<div>
  <p>You are missing the following materials to complete this recipe. 😪</p>
  <div class="missing-box">
    <div class="list">
      {#each Object.entries(missingObject) as [ingredient, count]}
        <div class="material">
          <img src="assets/materials/{ingredient}.svg" alt="Ingredient" />
          {count}
        </div>
      {/each}
    </div>
  </div>
  <a class="button" href="https://entrepot.app/marketplace/icpsquad2" target="_blank"> Buy </a>
</div>

<style lang="scss">
  @use "./src/website/src/styles" as *;

  .missing-box {
    background-color: $verydarkgrey;
    padding: 10px;
    max-width: 500px;
    margin-top: 20px;
    border-radius: 10px;
  }

  .list {
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
  }

  .material {
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
  .button {
    max-width: 500px;
    margin-top: 20px;
  }
</style>
