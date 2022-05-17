<script lang="ts">
  import { onMount } from "svelte";

  import AvatarZapAnimate from "./AvatarZapAnimate.svelte";

  enum Theme {
    PINK = "pink",
    PURPLE = "purple",
    YELLOW = "yellow",
    GREEN = "green",
  }

  type AnimatedItem = {
    image?: string;
    theme?: Theme;
    size: number;
    delay?: number;
  };

  type Set = AnimatedItem[];

  const sets: Set[] = [
    [
      {
        image: "pink-woman",
        theme: Theme.PINK,
        size: 2,
        delay: 0,
      },
      {
        size: 1,
      },
      {
        image: "blue-man",
        theme: Theme.PURPLE,
        size: 1,
        delay: 500,
      },
      {
        size: 1,
      },
      {
        image: "yellow-woman",
        theme: Theme.YELLOW,
        size: 1,
        delay: 1000,
      },
    ],
    [
      {
        image: "blue-man-2",
        theme: Theme.PURPLE,
        size: 1,
        delay: 500,
      },
      {
        image: "green-woman-2",
        theme: Theme.GREEN,
        size: 1,
        delay: 1000,
      },
      {
        size: 1,
      },
      {
        image: "pink-man",
        theme: Theme.PINK,
        size: 2,
        delay: 0,
      },
      {
        size: 1,
      },
      {
        image: "yellow-man-2",
        theme: Theme.YELLOW,
        size: 1,
        delay: 1000,
      },
    ],
    [
      {
        image: "yellow-woman-2",
        theme: Theme.YELLOW,
        size: 3,
        delay: 0,
      },
    ],
    [
      {
        image: "blue-man-3",
        theme: Theme.PURPLE,
        size: 1,
        delay: 500,
      },
      {
        image: "green-woman-3",
        theme: Theme.GREEN,
        size: 2,
        delay: 0,
      },
      {
        size: 1,
      },
      {
        image: "purple-man-2",
        theme: Theme.PINK,
        size: 1,
        delay: 1000,
      },
      {
        image: "green-man",
        theme: Theme.YELLOW,
        size: 1,
        delay: 1500,
      },
    ],
  ];

  const mobileImages: AnimatedItem[] = [
    {
      image: "pink-woman",
      theme: Theme.PINK,
      size: 1,
      delay: 0,
    },
    {
      image: "blue-man",
      theme: Theme.PURPLE,
      size: 1,
      delay: 500,
    },
    {
      image: "yellow-woman",
      theme: Theme.YELLOW,
      size: 1,
      delay: 1000,
    },
    {
      image: "blue-man-2",
      theme: Theme.PURPLE,
      size: 1,
      delay: 500,
    },
    {
      image: "green-woman-2",
      theme: Theme.GREEN,
      size: 1,
      delay: 1000,
    },
    {
      image: "pink-man",
      theme: Theme.PINK,
      size: 1,
      delay: 0,
    },
    {
      image: "yellow-woman-2",
      theme: Theme.YELLOW,
      size: 1,
      delay: 0,
    },
  ];

  let nowShowing = 0;
  let nowShowingMobile = 0;

  const startAnimation = () => {
    setInterval(() => {
      nowShowing = nowShowing == sets.length - 1 ? 0 : nowShowing + 1;
      nowShowingMobile =
        nowShowingMobile == mobileImages.length - 1 ? 0 : nowShowingMobile + 1;
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
        <div
          class="desktop"
          style="grid-column: span {item.size}; grid-row: span {item.size}"
        >
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
  {#each mobileImages as item, index}
    {#if nowShowingMobile == index}
      <div class="mobile">
        <AvatarZapAnimate
          image={item.image}
          theme={item.theme}
          size={2}
          delay={item.delay}
        />
      </div>
    {/if}
  {/each}
</div>

<style lang="scss">
  @use "../src/website/src/styles" as *;

  .grid {
    display: grid;
    --size: 140px;
    grid-template-columns: repeat(3, var(--size));
    grid-template-rows: repeat(3, var(--size));
    grid-gap: 20px;
    align-items: center;
  }

  .desktop {
    display: grid;
  }

  .mobile {
    display: none;
  }

  @media (max-width: 980px) {
    .grid {
      --size: 300px;
      grid-template-columns: var(--size);
      grid-template-rows: var(--size);
    }

    .desktop {
      display: none;
    }

    .mobile {
      display: grid;
    }
  }
</style>
