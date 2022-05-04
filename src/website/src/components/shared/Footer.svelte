<script lang="ts">
  import Logo from "@icons/Logo.svelte";
  import Discord from "@icons/Discord.svelte";
  import Twitter from "@icons/Twitter.svelte";

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
          label: "How it works",
          url: "/how-it-works",
        },
        {
          label: "Accessories",
          url: "/accessories",
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
          label: "Partners",
          url: "/partners",
        },
        {
          label: "Legendary Avatars",
          url: "/legendary",
        },
        {
          label: "Blog",
          url: "https://www.dfinitycommunity.com/tag/icpsquad/",
          external: true,
        },
      ],
    },
    {
      title: "Engage",
      items: [
        {
          label: "Create Avatar",
          url: "/create-avatar",
        },
        {
          label: "Dashboard",
          url: "/dashboard",
        },
        {
          label: "Stats",
          url: "/stats",
        },
        {
          label: "Discord",
          url: "https://discord.gg/SqtQ3UJR",
          external: true,
        },
        {
          label: "Twitter",
          url: "https://twitter.com/ICPSquadNFT",
          external: true,
        },
        {
          label: "Contact",
          url: "/contact",
        },
      ],
    },
  ];
</script>

<footer>
  <div class="container">
    <div class="top">
      <Logo />
      <div class="social">
        <a class="discord" href="https://discord.gg/SqtQ3UJR" target="_blank">
          <Discord />
        </a>
        <a href="https://twitter.com/ICPSquadNFT" target="_blank">
          <Twitter />
        </a>
      </div>
    </div>
    <nav>
      {#each footerNav as itemGroup}
        <div>
          <h3>{itemGroup.title}</h3>
          <div class="items">
            {#each itemGroup.items as item}
              <a
                class="item"
                href={item.url}
                target={item.external ? "_blank" : ""}>{item.label}</a
              >
            {/each}
          </div>
        </div>
      {/each}
    </nav>
  </div>
  <div class="sub-nav">
    <div class="container">
      © {new Date().getFullYear()} Dfinity community
      <a href="/privacy" class="privacy">Privacy Policy</a>
    </div>
  </div>
</footer>

<style lang="scss">
  @use "../../styles" as *;

  footer {
    --page-feature-color: #{$pink};
    border-top: 1px solid $verydarkgrey;
  }

  .top {
    margin-top: 40px;
    display: flex;
    flex-direction: row;
    justify-content: space-between;
    margin-bottom: 40px;
  }

  .social {
    display: flex;
    justify-content: center;
    .discord {
      margin-right: 14px;
    }
  }

  nav {
    display: grid;
    grid-template-columns: 1fr 1fr 1fr;
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

  .sub-nav {
    background-color: $verydarkgrey;
    .container {
      display: flex;
      justify-content: space-between;
      .privacy {
        color: $white;
      }
    }
  }
</style>
