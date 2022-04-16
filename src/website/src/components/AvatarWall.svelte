<script>
  import { onMount } from "svelte";

  import AvatarZapAnimate from "./AvatarZapAnimate.svelte";

  const sets = [
    [
      {
        image: "pink-woman",
        theme: "pink",
        size: 2,
        delay: 0,
      },
      {
        size: 1,
      },
      {
        image: "blue-man",
        theme: "purple",
        size: 1,
        delay: 500,
      },
      {
        size: 1,
      },
      {
        image: "yellow-woman",
        theme: "yellow",
        size: 1,
        delay: 1000,
      },
    ],
    [
      {
        image: "blue-man-2",
        theme: "purple",
        size: 1,
        delay: 500,
      },
      {
        image: "green-woman-2",
        theme: "green",
        size: 1,
        delay: 1000,
      },
      {
        size: 1,
      },
      {
        image: "pink-man",
        theme: "pink",
        size: 2,
        delay: 0,
      },
      {
        size: 1,
      },
      {
        image: "yellow-man-2",
        theme: "yellow",
        size: 1,
        delay: 1000,
      },
    ],
    [
      {
        image: "yellow-woman-2",
        theme: "yellow",
        size: 3,
        delay: 0,
      },
    ],
    [
      {
        image: "blue-man-3",
        theme: "purple",
        size: 1,
        delay: 500,
      },
      {
        image: "green-woman-3",
        theme: "green",
        size: 2,
        delay: 0,
      },
      {
        size: 1,
      },
      {
        image: "purple-man-2",
        theme: "pink",
        size: 1,
        delay: 1000,
      },
      {
        image: "green-man",
        theme: "yellow",
        size: 1,
        delay: 1500,
      },
    ],
  ];

  let nowShowing = 0;

  const startAnimation = () => {
    setInterval(() => {
      nowShowing = nowShowing == sets.length - 1 ? 0 : nowShowing + 1;
    }, 7000);
  };

  onMount(() => {
    startAnimation();
  });
</script>

<div class="grid">
  {#each sets as set, index}
    {#if nowShowing == index}
      {#each set as item}
        <div style="grid-column: span {item.size}; grid-row: span {item.size}">
          {#if item.image}
            <AvatarZapAnimate
              image={item.image}
              theme={item.theme}
              size={item.size}
              delay={item.delay}
            />
          {:else}
            <div />
          {/if}
        </div>
      {/each}
    {/if}
  {/each}
</div>

<style lang="scss">
  @use "./src/styles" as *;

  .grid {
    display: grid;
    grid-template-columns: 140px 140px 140px;
    grid-template-rows: 140px 140px 140px;
    grid-gap: 20px;
    align-items: center;
  }
</style>
