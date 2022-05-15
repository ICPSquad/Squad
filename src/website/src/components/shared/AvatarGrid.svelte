<script>
  import { fade } from "svelte/transition";

  const sets = [
    [1, 2, 3],
    [4, 5, 6],
    [7, 8, 9],
  ];

  let setShowing = 0;
  let visible = true;

  const fadeSeconds = 1;
  const holdSeconds = 8;
  const totalSeconds = holdSeconds + fadeSeconds * 2;

  setInterval(() => {
    visible = false;
    setTimeout(() => {
      setShowing = setShowing === 2 ? 0 : setShowing + 1;
      visible = true;
    }, fadeSeconds * 2 * 1000);
  }, totalSeconds * 1000);
</script>

<div class="wall-container">
  {#if visible}
    <div
      class="wall"
      in:fade={{ duration: fadeSeconds * 1000 }}
      out:fade={{ duration: fadeSeconds * 1000 }}
    >
      {#each sets as set, index}
        {#if setShowing === index}
          {#each set as image, imageIndex}
            <img
              class={imageIndex === 1 || imageIndex === 2
                ? "hide-on-mobile"
                : ""}
              src="/assets/join-wall/set{image}.png"
              alt="ICP Squad Avatars"
            />
          {/each}
        {/if}
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
    display: flex;
    justify-content: center;
    align-items: center;
  }
  img {
    width: 360px;
    height: 240px;
  }

  @media (max-width: 800px) {
    .hide-on-mobile {
      display: none;
    }
  }
</style>
