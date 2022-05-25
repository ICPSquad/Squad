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
    <button class="mint" on:click={handleSubmit}>
      <span class="hide-on-mobile">I'm ready to&nbsp;</span> mint →
    </button>
    <p class="small">Minting your avatar as an NFT costs 1 ICP</p>
  {/if}
</div>
<div id="avatar-components">
  <AvatarComponentsSvg />
</div>

<style lang="scss">
  @use "./src/website/src/styles" as *;

  #avatar-components {
    width: 0;
    height: 0;
  }
  button.mint {
    margin-top: 20px;
    width: 100%;
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
      padding: 12px 8px 8px 8px;
    }
  }

  @media (max-width: 960px) {
    .hide-on-mobile {
      display: none;
    }

    button.shuffle {
      --size: 40px;
    }

    p.small {
      font-size: 0.7rem;
    }

    button.mint {
      margin-top: 10px;
    }
  }

  @media (max-width: 600px) {
    button.shuffle {
      --size: 24px;
      top: 4px;
      right: 4px;
      .shuffle-icon {
        padding: 4px 4px 4px 4px;
      }
    }
  }
</style>
