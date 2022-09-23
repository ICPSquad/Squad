<script lang="ts">
  import { Link } from "svelte-routing";

  export let textAlignCenter = false;
  export let closeMenu = () => {};

  type LinkItem = {
    label: string;
    url: string;
    external?: boolean;
  };

  type LinkGroup = {
    title: string;
    items: LinkItem[];
  };

  const footerNav: LinkGroup[] = [
    {
      title: "Learn",
      items: [
        {
          label: "FAQs",
          url: "/faqs",
        },
        {
          label: "Accessories",
          url: "/accessories",
        },
        {
          label: "Blog",
          url: "https://www.dfinitycommunity.com/tag/icpsquad/",
          external: true,
        },
        {
          label: "Documentation",
          url: "https://dsquad.gitbook.io/docs/",
          external: true,
        },
      ],
    },
    {
      title: "Create",
      items: [
        {
          label: "Create Avatar",
          url: "/create-avatar",
        },
        {
          label: "Create Accessory",
          url: "/create-accessory",
        },
      ],
    },
    {
      title: "Engage",
      items: [
        {
          label: "Equip accessory",
          url: "/equip-accessory",
        },
        {
          label: "Leaderboard",
          url: "/leaderboard",
        },
        {
          label: "Mission",
          url: "/mission",
        },
        {
          label: "Activity",
          url: "/activity",
        },
      ],
    },
    {
      title: "The Squad",
      items: [
        {
          label: "About Us",
          url: "/about-us",
        },
        {
          label: "Roadmap",
          url: "/roadmap",
        },
        {
          label: "Partners",
          url: "/partners",
        },
        {
          label: "Legendary Avatars",
          url: "/legendary-avatars",
        },
      ],
    },
  ];
</script>

<nav>
  {#each footerNav as itemGroup}
    <div>
      <h3 style="text-align: {textAlignCenter ? 'center' : 'left'}">
        {itemGroup.title}
      </h3>
      <div class="items">
        {#each itemGroup.items as item}
          {#if item.external}
            <a class="item" style="text-align: {textAlignCenter ? 'center' : 'left'}" href={item.url} target={item.external ? "_blank" : ""}>{item.label} </a>
          {:else}
            <Link on:click={closeMenu} to={item.url}>
              <div class="item" style="text-align: {textAlignCenter ? 'center' : 'left'}">
                {item.label}
              </div>
            </Link>
          {/if}
        {/each}
      </div>
    </div>
  {/each}
</nav>

<style lang="scss">
  @use "../../styles" as *;

  nav {
    --page-feature-color: #{$pink};
    width: 100%;
    display: grid;
    grid-template-columns: 1fr 1fr 1fr 1fr;
    grid-gap: 40px;
    margin-bottom: 40px;
  }

  .items {
    display: flex;
    flex-direction: column;
  }

  h3 {
    color: var(--page-feature-color);
    text-transform: uppercase;
    font-size: 20px;
  }

  .item {
    color: $white;
    margin-bottom: 8px;
    &:hover {
      text-decoration: underline;
    }
  }

  @media (max-width: 600px) {
    nav {
      grid-template-columns: 100%;
    }
  }
</style>
