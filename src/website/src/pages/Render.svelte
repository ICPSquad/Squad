<script lang="ts">
  import AvatarComponentsSvg from "@src/components/AvatarComponentsSvg.svelte";
  import RenderAvatar from "@src/components/render/RenderAvatar.svelte";
  import { generateRandomAvatar } from "@src/tasks/generate-avatar";
  import type { AvatarComponents } from "@src/types/avatar";
  import type { AvatarColors } from "@src/types/color";
  import { generateRandomColor } from "@src/utils/color";

  let colors_a: AvatarColors = generateRandomColor();

  // let colors_a: AvatarColors = {
  //   background: [143, 203, 193, 1],
  //   skin: [244, 175, 118, 1],
  //   hairs: [167, 76, 1, 1],
  //   eyes: [30, 112, 220, 1],
  //   eyebrows: [167, 76, 1, 1],
  //   eyeliner: [73, 141, 28, 1],
  //   clothes: [167, 126, 11, 1],
  // };

  let components_a: AvatarComponents = {
    background: "background-base",
    profile: "business-profile",
    ears: "business-ears",
    mouth: "business-mouth",
    eyes: "business-uninterested-eyes",
    nose: "punk-nose",
    hairs: "hair-15",
    clothes: "3",
    hat: "",
    glasses: "",
    face: "evil-mask",
    body: "devil-jacket",
    misc: "sunrise",
  };

  let components_c: AvatarComponents = generateRandomAvatar(1);
</script>

<div class="avatars">
  <img src="assets/banner/2.png" alt="" />
  <img src="assets/banner/1.png" alt="" />
  <img src="assets/banner/3.png" alt="" />
</div>

<style>
  .avatars {
    display: flex;
    direction: row;
    align-items: center;
    justify-items: center;
    width: 1000px;
    height: 1000px;
  }

  img {
    width: 800px;
    height: 800px;
  }
</style>
