<script>
  import AccessoryCardTemplate from "./AccessoryCardTemplate.svelte";
  import { categoryToAccessories } from "@utils/list";
  import { createEventDispatcher } from "svelte";
  let dispatch = createEventDispatcher();

  export let category = "hat";

  $: accessories = categoryToAccessories(category);

  const handleMouseEnter = (e) => {
    let { name, isEquipped } = e.detail;
    dispatch("mouseEnterCard", { name, isEquipped });
  };

  const handleMouseExit = (e) => {
    let { name, isEquipped } = e.detail;
    dispatch("mouseExitCard", { name, isEquipped });
  };
</script>

<div class="list">
  {#each accessories as accessory}
    <div class="list-item">
      <AccessoryCardTemplate name={accessory.name} {category} on:mouseEnterCard={handleMouseEnter} on:mouseExitCard={handleMouseExit} />
    </div>
  {/each}
</div>

<style lang="scss">
  @use "../../styles" as *;
  .list {
    display: flex;
    flex-wrap: wrap;
    flex-direction: row;
    justify-content: flex-start;
    align-items: center;
    margin-top: 20px;
  }
  .list-item {
    margin-right: 20px;
    margin-bottom: 20px;
  }
</style>
