<script lang="ts">
  import RenderAvatar from "../components/render/RenderAvatar.svelte";
  import AvatarComponentsSvg from "@src/components/AvatarComponentsSvg.svelte";
  import { generateRandomColor } from "@src/utils/color";
  import type { AvatarComponents } from "../types/avatar.d";

  let components: AvatarComponents = {
    background: "background-base",
    profile: "punk-profile",
    ears: "punk-ears",
    mouth: "business-mouth",
    eyes: "punk-confident-eyes",
    nose: "miss-nose",
    hairs: "hair-1",
    clothes: "1",
    body: "astro-suit",
  };
</script>

<div>
  <div class="svg">
    <AvatarComponentsSvg />
  </div>
  <div class="avatar">
    <RenderAvatar avatarColors={generateRandomColor()} avatarComponents={components} />
  </div>
</div>

<style>
  .svg {
    height: 0px;
  }
</style>
