<script lang="ts">
  import Description from "./Description.svelte";
  import AccessoryDetails from "./AccessoryDetails.svelte";
  import Recipe from "./Recipe.svelte";
  import type { Recipe as RecipeType } from "@canisters/accessories/accessories.did.d";
  // Recipe
  export let recipe: RecipeType;

  // Price and suplly informations about the accessory
  export let supply: number | null = null;
  export let floorPrice: number | null = null;

  // Description
  export let description: string | undefined;
</script>

<AccessoryDetails {supply} {floorPrice} />
<Description {description} />
<Recipe {recipe} />
