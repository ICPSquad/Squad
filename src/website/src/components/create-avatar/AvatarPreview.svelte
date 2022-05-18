<script lang="ts">
  import Shuffle from "@src/icons/Shuffle.svelte";
  import AvatarComponentsSvg from "../AvatarComponentsSvg.svelte";
  import RenderAvatar from "../render/RenderAvatar.svelte";
  import type { State } from "./types";

  export let components;
  export let randomlyResetAvatar;
  export let colors;
  export let handleSubmit;
  export let state: State;
</script>

<div class="avatar">
  {#if state === "creating-avatar"}
    <button class="shuffle" on:click={randomlyResetAvatar}>
      <div class="shuffle-icon">
        <Shuffle />
      </div>
    </button>
  {/if}
  <RenderAvatar avatarComponents={components} avatarColors={colors} />
  {#if state === "creating-avatar"}
    <button class="mint" on:click={handleSubmit}> I'm ready to mint → </button>
    <p class="small">Minting your avatar as an NFT costs 1 ICP</p>
  {/if}
</div>
<div id="avatar-components">
  <AvatarComponentsSvg />
</div>

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
  #avatar-components {
    width: 0;
    height: 0;
  }
  button.mint {
    margin-top: 20px;
  }
  p.small {
    font-size: 0.9rem;
    text-align: center;
    margin-top: 10px;
  }

  .avatar {
    position: relative;
  }
  button.shuffle {
    position: absolute;
    --size: 54px;
    width: var(--size);
    height: var(--size);
    padding: 0;
    border-radius: 50%;
    background-color: $black;
    border: 2px solid $green;
    right: 10px;
    top: 10px;
    .shuffle-icon {
      padding-top: 4px;
    }
  }
</style>
