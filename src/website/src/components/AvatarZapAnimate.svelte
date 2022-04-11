<script>
  import { tweened } from "svelte/motion";
  import { cubicOut } from "svelte/easing";
  import { onMount } from "svelte";

  export let image = "purple-woman";
  export let theme = "pink";
  export let size = 1;

  const pxSize = {
    1: 140,
    2: 300,
    3: 460,
  };

  const color = {
    pink: {
      border: "D51D81",
      shadow: "FFC5E7",
    },
    yellow: {
      border: "F8B13A",
      shadow: "FFDEA8",
    },
    green: {
      border: "86F132",
      shadow: "CFFCAB",
    },
    purple: {
      border: "4D4BC3",
      shadow: "B8B7FF",
    },
  };

  const opacity = tweened(0, {
    duration: 100,
    easing: cubicOut,
  });

  const height = tweened(0, {
    duration: 100,
    easing: cubicOut,
  });

  const startAnimation = async () => {
    await opacity.set(1);
    await height.set(pxSize[size]);
    setTimeout(async () => {
      // await height.set(0);
      // opacity.set(0);
    }, 8000);
  };

  onMount(() => {
    startAnimation();
  });
</script>

<div
  style="width: {pxSize[size]}px;
    opacity: {$opacity};
    height: {$height}px;
    border: #{color[theme].border} 5px solid;
    box-shadow: 0 0 30px #{color[theme].shadow}50;
    filter: drop-shadow(0px 0px 8px #{color[theme].shadow})"
>
  <img
    style="width: {pxSize[size] - 30}px"
    src="/assets/avatars/{image}.png"
    alt="ICP Squad Avatar of {image}"
  />
</div>

<style lang="scss">
  @use "./src/styles" as *;

  div {
    border-radius: 6px;
    overflow: hidden;

    img {
      margin: 10px;
    }
  }
</style>
