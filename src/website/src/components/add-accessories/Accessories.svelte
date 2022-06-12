<script>
  import Carat from "@icons/Carat.svelte";
  import { categoryDisplayName } from "@utils/categories";
  import ListAccessories from "@components/add-accessories/ListAccessories.svelte";
  export let category = "";
  let open = false;
  import { createEventDispatcher } from "svelte";
  let dispatch = createEventDispatcher();

  const handleMouseEnter = (e) => {
    let { name, isEquipped } = e.detail;
    dispatch("mouseEnterCard", { name, isEquipped });
  };

  const handleMouseExit = (e) => {
    let { name, isEquipped } = e.detail;
    dispatch("mouseExitCard", { name, isEquipped });
  };
</script>

<div class="accessories">
  <div on:click={() => (open = !open)} class="accessories-header">
    <h3>{categoryDisplayName[category]}</h3>
    <Carat rotate={open ? -90 : 90} />
  </div>
  {#if open}
    <ListAccessories {category} on:mouseEnterCard={handleMouseEnter} on:mouseExitCard={handleMouseExit} />
  {/if}
</div>

<style lang="scss">
  @use "../../styles" as *;
  h3 {
    margin-bottom: 0;
    font-size: min(max(1rem, 1.5vw), 1.8rem); // Min, Variable, Max
  }
  .accessories {
    background-color: $verydarkgrey;
    padding: 20px;
    border-radius: 10px;
    color: $lightgrey;
    margin-bottom: 10px;
  }
  .accessories-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    cursor: pointer;
  }
</style>
