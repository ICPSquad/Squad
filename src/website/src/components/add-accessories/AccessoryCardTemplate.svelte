<script>
  import { nameToRecipe } from "@src/utils/recipes";

  import { createEventDispatcher } from "svelte";
  let dispatch = createEventDispatcher();

  export let name;
  export let category;
  let isEquipped = false;
  const handleMouseEnter = () => {
    dispatch("mouseEnterCard", { name, isEquipped });
  };

  const handleMouseExit = () => {
    dispatch("mouseExitCard", { name, isEquipped });
  };
  let recipe = nameToRecipe(name);

  /*
    Format the recipe to be able to use it in the template and iterate over it (array like format)
  */
  function recipeFormat(recipeArray) {
    let recipeObject = {};
    recipeArray.forEach((material) => {
      recipeObject[material] ? recipeObject[material]++ : (recipeObject[material] = 1);
    });
    let recipeArrayFormatted = [];
    for (let key in recipeObject) {
      recipeArrayFormatted.push([key, recipeObject[key]]);
    }
    return recipeArrayFormatted;
  }

  $: recipeFormat = recipeFormat(recipe);
</script>

<div class="accessory">
  <div class="image" on:mouseenter={handleMouseEnter} on:mouseleave={handleMouseExit}>
    <img src={`assets/accessories/${category}/${name}/${name}-card.svg`} alt="Accessory Card" />
    <div class="hover">
      <div class="recipe">
        <h4>{name}</h4>
        {#each recipeFormat as recipe}
          <div class="recipe-item">
            <div class="line">
              <span class="number"> {recipe[1]}x</span> <span class="name"> {recipe[0]}</span>
            </div>
          </div>
        {/each}
      </div>
    </div>
  </div>
</div>

<style lang="scss">
  @use "../../styles" as *;
  img {
    width: 200px;
  }

  .accessory {
    .image {
      position: relative;

      .hover {
        position: absolute;
        width: 100%;
        height: 100%;
        top: 0;
        left: 0;
        background-color: #000000cc;
        display: flex;
        flex-direction: column;
        justify-content: center;
        align-items: center;
        padding: 20px;
        opacity: 0;
        &:hover {
          opacity: 100;
        }
      }

      .legend-link {
        margin: 7px 0px;
        border: 1px solid $white;
        background-color: transparent;
        border-radius: 100px;
        &:hover {
          background-color: #00000033;
        }
      }
    }
  }
  .recipe {
    display: flex;
    flex-direction: column;
    justify-content: space-around;
    align-items: center;
  }
  h4 {
    color: $blue;
    text-transform: uppercase;
    margin: 5px 0px;
  }

  .number {
    color: $blue;
    font-weight: bold;
    font-size: medium;
  }
  .name {
    text-transform: capitalize;
    font-weight: bold;
    font-size: small;
  }
</style>
