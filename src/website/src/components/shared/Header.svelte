<script lang="ts">
  import { Link } from "svelte-routing";
  import Logo from "@icons/Logo.svelte";
  import MenuIcon from "@icons/Menu.svelte";
  import { user } from "@src/store/user";
  import { plugConnection } from "@utils/connection";
  import Discord from "@icons/Discord.svelte";
  import Twitter from "@icons/Twitter.svelte";
  import Cross from "@src/icons/Cross.svelte";
  import Menu from "./Menu.svelte";

  let menuOpen: boolean = false;

  const closeMenu = () => {
    menuOpen = false;
  };
</script>

{#if menuOpen}
  <Menu {closeMenu} />
{/if}
<nav class="container">
  <Link to="/">
    <Logo />
  </Link>
  <div class="right">
    {#if !menuOpen}
      <div class="hide-on-mobile">
        <a
          class="social-icon discord"
          href="https://discord.gg/SqtQ3UJR"
          target="_blank"
        >
          <Discord width={20} />
        </a>
        <a
          class="social-icon"
          href="https://twitter.com/ICPSquadNFT"
          target="_blank"
        >
          <Twitter width={20} />
        </a>
        <button on:click={plugConnection}>
          {$user.loggedIn ? "You are connected" : "Connect your wallet"}
        </button>
      </div>
    {/if}
    <div class="menu-open-close" on:click={() => (menuOpen = !menuOpen)}>
      {#if !menuOpen}
        <MenuIcon />
      {:else}
        <Cross />
      {/if}
    </div>
  </div>
</nav>

<style lang="scss">
  @use "./src/website/src/styles" as *;

  nav {
    position: relative;
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding-top: 30px;
    padding-bottom: 30px;
    z-index: 99;
  }

  .right,
  .hide-on-mobile {
    display: flex;
    align-items: center;
    justify-content: center;
  }

  button {
    border: 3px solid $pink;
    background-color: transparent;
    border-radius: 40px;
    margin-right: 20px;
    font-size: 1rem;
  }

  .social-icon {
    margin-right: 20px;
  }

  .menu-container {
    width: 100%;
    height: 100vh;
    background-color: $black;
    display: flex;
    z-index: 10;
  }

  .menu-nav-container {
    width: 1100px;
    max-width: 100%;
    margin: 80px auto;
  }

  .menu-open-close {
    cursor: pointer;
    width: 50px;
    height: 50px;
    display: flex;
    justify-content: center;
    align-items: center;
  }

  @media (max-width: 800px) {
    .hide-on-mobile {
      display: none;
    }

    .menu-open-close {
      width: 26px;
      height: 26px;
    }

    nav {
      padding-top: 20px;
      padding-bottom: 20px;
    }
  }
</style>
