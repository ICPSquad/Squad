<script>
  import AvatarComponentsSvg from "@components/AvatarComponentsSvg.svelte";
  import RenderAvatar from "@components/render/RenderAvatar.svelte";
  import { generateRandomColor } from "@src/utils/color";
  import { generateRandomAvatar, filterOption } from "@tasks/generate-avatar";

  export let speed = 1; // Num between 0 and 1. 1 = fastest
  export let backwards = true;

  const items = new Array(30);

  const animation = `<style> @keyframes scrollingavatars { 0% { margin-left: 0px; } 100% { margin-left: calc(100% - 1800px); } } </style>`;
</script>

<div id="avatar-components">
  <AvatarComponentsSvg />
</div>

<div class="line-container">
  <div
    class="line"
    style="animation-name: scrollingavatars; animation-duration:{200 /
      speed}s; animation-direction: {backwards
      ? 'alternate'
      : 'alternate-reverse'}; "
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
  {@html animation}
</div>

<style lang="scss">
  #avatar-components {
    height: 0px;
    width: 0px;
  }
  .line-container {
    position: relative;
    width: 100%;
    overflow: hidden;
    margin-bottom: 10px;
  }
  .line {
    width: 1800px;
    height: 50px;
    animation-iteration-count: infinite;
    animation-timing-function: linear;
  }
  .avatar {
    display: inline-block;
    width: 50px;
    height: 50px;
    margin-right: 10px;
    border-radius: 50%;
    overflow: hidden;
  }
</style>
