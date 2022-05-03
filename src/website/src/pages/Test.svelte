<script lang="ts">
  import AvatarComponentsSvg from "../components/AvatarComponentsSvg.svelte";
  import RenderAvatar from "../components/render/RenderAvatar.svelte";
  import type { AvatarComponents } from "../types/avatar";
  let avatar: AvatarComponents = {
    background: "background-base",
    profile: "miss-profile",
    ears: "miss-ears",
    mouth: "",
    eyes: "",
    nose: "",
    hair: "",
    clothes: "",
    accessoryHat: "mortaboard-hat",
    accessoryEyes: "",
    accessoryFace: "",
    accessoryBody: "assassin-cap",
    accessoryMisc: "",
  };
</script>

<div id="avatar-components">
  <AvatarComponentsSvg />
</div>
<RenderAvatar avatarComponents={avatar} />

<style>
  #avatar-components {
    height: 0px;
    width: 1px;
  }

</style>
