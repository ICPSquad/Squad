<script>
  import AvatarComponentsSvg from "@components/AvatarComponentsSvg.svelte";
  import RenderAvatar from "@components/render/RenderAvatar.svelte";
  import { generateRandomColor } from "@src/utils/color";
  import { generateRandomAvatar, filterOption } from "@tasks/generate-avatar";

  const items = new Array(60);
</script>

<div id="avatar-components">
  <AvatarComponentsSvg />
</div>

<section>
  <div class="wall-container">
      {#each items as item}
        <div class="avatar">
          <RenderAvatar avatarComponents={generateRandomAvatar(0, Math.random() > 0.5 ? filterOption.Man : filterOption.Woman)} avatarColors={generateRandomColor()} />
        </div>
      {/each}
  </div>
</section>


<style>
  #avatar-components {
    height: 0px;
    width: 0px;
  }
  section {
    width: 100%;
    display: flex;
    justify-content: center;
  }
  .wall-container {
    margin: 40px;
    display: grid;
    grid-template-columns: repeat(12, 100px);
    grid-gap: 10px
  }
  .avatar {
    display: inline-block;
    width: 100px;
    height: 100px;
    margin-right: 10px;
    border-radius: 50%;
    overflow: hidden;
  }
</style>
