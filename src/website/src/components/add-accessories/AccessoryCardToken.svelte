<script>
  import { createEventDispatcher } from "svelte";
  let dispatch = createEventDispatcher();

  export let name;
  export let tokenId;
  export let isEquipped;
  export let isSlotEquipped;

  $: stateToText = () => {
    if (isEquipped) {
      return "Remove from avatar";
    } else {
      if (isSlotEquipped) {
        return "Slot is equipped";
      } else {
        return "Add to avatar";
      }
    }
  };

  const handleMouseEnter = () => {
    dispatch("mouseEnterCard", { name, tokenId, isEquipped });
  };

  const handleMouseExit = () => {
    dispatch("mouseExitCard", { name, tokenId, isEquipped });
  };

  const handleClick = () => {
    dispatch("clickCard", { name, tokenId, isEquipped });
  };
</script>

<div class="accessory" on:mouseenter={handleMouseEnter} on:mouseleave={handleMouseExit}>
  <div class="image">
    <img src={`https://po6n2-uiaaa-aaaaj-qaiua-cai.raw.ic0.app/tokenid=${tokenId}`} alt={`${name}`} />
    <div class="hover">
      <button on:click={handleClick} class="button legend-link">{stateToText()}</button>
    </div>
  </div>
  <h3>{name}</h3>
</div>

<style lang="scss">
  @use "../../styles" as *;

  h3 {
    color: $blue;
    text-transform: uppercase;
    text-align: center;
    margin-top: 12px;
    margin-bottom: 4px;
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
  img {
    height: 250px;
    margin: 0 auto;
  }
</style>
