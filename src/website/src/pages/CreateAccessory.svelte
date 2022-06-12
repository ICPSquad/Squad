<script lang="ts">
  import Header from "@src/components/shared/Header.svelte";
  import Footer from "@src/components/shared/Footer.svelte";
  import Categories from "@src/components/create-accessory/Categories.svelte";
  import CardSelection from "@src/components/create-accessory/CardSelection.svelte";
  import Checkout from "@src/components/create-accessory/Checkout.svelte";
  import { accessoriesActor } from "@src/api/actor";
  import { nameToDescription, nameToRecipe } from "@utils/recipes";
  import { nameToStats } from "@src/utils/stats";
  import type { State } from "@src/components/create-accessory/types";
  import AccessoryInfos from "@src/components/create-accessory/AccessoryInfos.svelte";

  let categoryShowing: string = "hat";
  const setCategoryShowing = (category: string) => {
    categoryShowing = category;
  };

  let cardSelected: string = "helicap";
  const setCardSelected = (card: string) => {
    cardSelected = card;
  };

  let state: State = "creating-accessory";
  let setState = (newState: State) => {
    state = newState;
  };

  $: recipe = nameToRecipe(cardSelected);
  $: description = nameToDescription(cardSelected);
  $: stats = nameToStats(informations, capitalizeFirstLetter(cardSelected));

  function capitalizeFirstLetter(string: string) {
    return string.charAt(0).toUpperCase() + string.slice(1);
  }

  // Supply & prices informations  querried from the accessory canister.
  let informations;
  accessoriesActor()
    .get_stats_items()
    .then((stats) => {
      informations = stats;
    });

  function handleMint() {
    state = "waiting-wallet-connection";
  }
</script>

<Header />
<div class="page-header">
  <h1>Create Accessory</h1>
</div>
<main class="container">
  <div class="layout-grid">
    {#if state === "creating-accessory"}
      <div class="categories">
        <Categories {categoryShowing} {setCategoryShowing} />
      </div>
      <div class="item-selection">
        <CardSelection {categoryShowing} {cardSelected} {setCardSelected} />
      </div>
    {:else}
      <Checkout {state} {setState} {cardSelected} />
    {/if}
    <div class="accessory-details">
      <AccessoryInfos {recipe} {description} supply={stats[0]} floorPrice={stats[1]} />
      {#if recipe.length > 0 && state === "creating-accessory"}
        <button class="mint" on:click={handleMint}> Mint </button>
        <p class="small">Minting an accessory requires to burn the necessary materials with a fee of 0.5 ICP</p>
      {/if}
    </div>
  </div>
</main>
<Footer />

<style lang="scss">
  @use "./src/website/src/styles" as *;

  main {
    --page-feature-color: #{$pink};
  }
  .layout-grid {
    display: grid;
    grid-template-columns: 1fr 1fr 1fr;
    grid-gap: 40px;
  }

  @media (max-width: 960px) {
    .layout-grid {
      grid-template-columns: 3fr 3fr 4fr;
      grid-gap: 10px;
      grid-auto-flow: dense;
    }
    .categories {
      grid-column: span 2;
    }
    .item-selection {
      grid-column: span 2;
    }
    .accessory-details {
      grid-row: span 2;
    }
  }

  p.small {
    font-size: 0.9rem;
    text-align: center;
    margin-top: 10px;
  }
</style>
