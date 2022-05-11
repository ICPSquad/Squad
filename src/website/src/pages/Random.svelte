<script>
  import AvatarComponentsSvg from "@components/AvatarComponentsSvg.svelte";
  import RenderAvatar from "@components/render/RenderAvatar.svelte";
  import { generateRandomColor } from "@src/utils/color";
  import { generateRandomAvatar, filterOption } from "@tasks/generate-avatar";
</script>

<div id="avatar-components">
  <AvatarComponentsSvg />
</div>

<div class="container">
  <div class="content">
    <RenderAvatar
      avatarComponents={generateRandomAvatar(
        0,
        Math.random() > 0.5 ? filterOption.Man : filterOption.Woman
      )}
      avatarColors={generateRandomColor()}
    />
  </div>
</div>

<style>
  #avatar-components {
    height: 0px;
    width: 1px;
  }
  .container {
    display: flex;
    flex-direction: row;
    justify-content: space-between;
  }

  .content {
    width: 800px;
    margin: 0 auto;
  }
</style>
