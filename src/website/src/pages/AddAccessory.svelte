<script lang="ts">
  import Header from "@src/components/shared/Header.svelte";
  import Footer from "@src/components/shared/Footer.svelte";
  import Accessories from "@components/add-accessories/Accessories.svelte";
  import AccessoryCardToken from "@src/components/add-accessories/AccessoryCardToken.svelte";
  import type { AvatarColors } from "@src/types/color";
  import type { AvatarComponents } from "@src/types/avatar";
  import type { TokenIdentifier } from "@canisters/avatar/avatar.did.d";
  import { avatar, updateAvatar } from "../store/avatar";
  import { user } from "../store/user";
  import { getAccessories, inventory, updateInventory } from "../store/inventory";
  import { plugConnection } from "@utils/connection";
  import RenderAvatar from "@src/components/render/RenderAvatar.svelte";
  import AvatarComponentsSvg from "@src/components/AvatarComponentsSvg.svelte";
  import { renderingToColorsAndComponents, isEquipped } from "@utils/avatar";
  import { nameToSlotAccessory } from "@utils/list";
  import { removeAccessory, wearAccessory } from "@utils/accessories";

  const categories = ["hat", "face", "eyes", "body", "misc"];

  let colors: AvatarColors;
  let components: AvatarComponents;
  let accessories: Array<[string, TokenIdentifier, boolean]> = [];
  let tokenId: string | undefined;
  let hover: boolean = false;
  $: hover_components = hover ? hover_components : { ...components };

  avatar.subscribe((data) => {
    if (!data.rendering || !data.tokenIdentifier) return;
    let result = renderingToColorsAndComponents(data.rendering);

    tokenId = data.tokenIdentifier;
    colors = result[0];
    components = result[1];
  });

  inventory.subscribe((data) => {
    if (!data) return;
    accessories = getAccessories(data);
  });

  setInterval(() => {
    updateAvatar();
    updateInventory();
  }, 3000);

  function handleMouseEnter(e) {
    hover = true;
    let name = e.detail.name;
    let isEquipped = e.detail.isEquipped;
    if (isEquipped) return;
    let slot = nameToSlotAccessory(name);
    hover_components[slot] = name;
  }

  function handleMouseExit(e) {
    let isEquipped = e.detail.isEquipped;
    if (isEquipped) return;
    let name = e.detail.name;
    let slot = nameToSlotAccessory(name);
    hover_components[slot] = undefined;
    hover = false;
  }

  async function handleClick(e) {
    let isEquipped = e.detail.isEquipped;
    let accessoryId = e.detail.tokenId;
    let name = e.detail.name;
    if (isSlotEquipped(name) && !isEquipped) {
      return;
    }
    let confirm_message = isEquipped
      ? "Are you sure you want to unequip this accessory?\nThe wear value will be decreased by one and your avatar will be modified."
      : "Are you sure you want to equip this accessory?\nThe wear value will be decreased by one and your avatar will be modified.";
    if (!confirm(confirm_message)) return;
    let result;
    if (isEquipped) {
      result = await removeAccessory(accessoryId, tokenId);
    } else {
      result = await wearAccessory(accessoryId, tokenId);
    }
    if ("err" in result) {
      alert(result.err);
      return;
    } else {
      alert("Success! Your avatar has been successfully updated.");
      if (isEquipped) {
        components[nameToSlotAccessory(e.detail.name)] = undefined;
      } else {
        components[nameToSlotAccessory(e.detail.name)] = e.detail.name;
      }
    }
  }

  function isSlotEquipped(name: string): boolean {
    let slot = nameToSlotAccessory(name);
    if (components[slot]) {
      return true;
    }
    return false;
  }
</script>

<Header />
<div class="page-header">
  <h1>Add accessory</h1>
</div>
<main class="container">
  {#if !$user.loggedIn}
    <p>Please connect a wallet to continue</p>
    <button on:click={() => plugConnection()}>Plug wallet</button>
  {:else if colors === null || components === null}
    <p>Please wait</p>
  {:else if colors && components}
    <div class="layout-grid">
      <div class="avatar-preview">
        <h3>MY AVATAR</h3>
        {#if hover}
          <RenderAvatar avatarColors={colors} avatarComponents={hover_components} />
        {:else}
          <RenderAvatar avatarColors={colors} avatarComponents={components} />
        {/if}
      </div>
      <div id="avatar-components">
        <h3>MY ACCESSSORIES</h3>
        <div class="my-accessories">
          {#each accessories as [name, token, equipped]}
            <AccessoryCardToken
              {name}
              tokenId={token}
              isEquipped={equipped}
              isSlotEquipped={isSlotEquipped(name)}
              on:mouseEnterCard={handleMouseEnter}
              on:mouseExitCard={handleMouseExit}
              on:clickCard={handleClick}
            />
          {/each}
        </div>
        <h3>VIEW ALL ACCESSORIES</h3>
        <div class="all-accessories">
          {#each categories as category}
            <Accessories {category} />
          {/each}
        </div>
      </div>
      <div class="avatar-preview">
        <AvatarComponentsSvg />
      </div>
    </div>
  {/if}
</main>

<Footer />

<style lang="scss">
  @use "./src/website/src/styles" as *;

  h1 {
    --page-feature-color: #{$blue};
  }

  h3 {
    color: $white;
    text-transform: uppercase;
    text-align: center;
  }

  .avatar-preview {
    grid-row: span 2;
  }

  .layout-grid {
    display: grid;
    grid-template-columns: 30% 70%;
    grid-column-gap: 40px;
  }

  .my-accessories {
    display: flex;
    flex-direction: row;
    flex-wrap: wrap;
    justify-content: flex-start;
    align-items: center;
    margin-top: 20px;
    margin-bottom: 20px;
    row-gap: 20px;
    column-gap: 20px;
  }
</style>
