<script>
  import AvatarComponentsSvg from "@components/AvatarComponentsSvg.svelte";
  import RenderAvatar from "@components/render/RenderAvatar.svelte";
  import { generateRandomColor } from "@src/utils/color";
  import { generateRandomAvatar, filterOption } from "@tasks/generate-avatar";
  import { fade } from "svelte/transition";
  import { elasticOut } from "svelte/easing";

  let visible = true;

  const numAvatars = 18 * 4;
  let items = new Array(numAvatars);

  const fadeSeconds = 1;
  const holdSeconds = 8;
  const totalSeconds = holdSeconds + fadeSeconds * 2;

  setInterval(() => {
    visible = false;
    setTimeout(() => {
      visible = true;
    }, fadeSeconds * 2 * 1000);
  }, totalSeconds * 1000);
</script>

<div id="avatar-components">
  <AvatarComponentsSvg />
</div>

<div class="wall-container">
  {#if visible}
    <div
      class="wall"
      in:fade={{ duration: fadeSeconds * 1000 }}
      out:fade={{ duration: fadeSeconds * 1000 }}
    >
      {#each items as item}
        <div class="avatar">
          <RenderAvatar
            avatarComponents={generateRandomAvatar(
              0,
              Math.random() > 0.5 ? filterOption.Man : filterOption.Woman
            )}
            avatarColors={generateRandomColor()}
          />
        </div>
      {/each}
    </div>
  {/if}
</div>

<style lang="scss">
  #avatar-components {
    height: 0px;
    width: 0px;
  }
  .wall-container {
    height: 230px;
  }
  .wall {
    display: grid;
    grid-template-columns: repeat(18, 50px);
    grid-gap: 10px;
  }
  .avatar {
    display: inline-block;
    width: 50px;
    height: 50px;
    border-radius: 50%;
    overflow: hidden;
  }
</style>
