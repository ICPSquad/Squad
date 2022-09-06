<script lang="ts">
  import Discord from "@src/icons/Discord.svelte";
  import Twitter from "@src/icons/Twitter.svelte";
  import FooterNav from "./FooterNav.svelte";
  import { user } from "@src/store/user";
  import { disconnectWallet } from "@utils/connection";
  import LinkButton from "./LinkButton.svelte";

  import ConnectButton from "@src/components/shared/ConnectButton.svelte";
  export let closeMenu;

  const disconnect = () => {
    closeMenu();
    disconnectWallet();
  };
</script>

<div class="menu-container">
  <div class="container menu-nav-container">
    <div class="connexion">
      {#if !$user.loggedIn}
        <ConnectButton />
      {:else}
        <LinkButton to="/profile">
          <button> Profile </button>
        </LinkButton>
        <button on:click={disconnect}>Sign out</button>
      {/if}
    </div>
    <FooterNav textAlignCenter {closeMenu} />
    <div class="social-icons">
      <a class="discord" href="https://discord.gg/9DjDzf38WR" target="_blank">
        <Discord width={40} />
      </a>
      <a href="https://twitter.com/ICPSquadNFT" target="_blank">
        <Twitter width={40} />
      </a>
    </div>
  </div>
</div>

<style lang="scss">
  @use "./src/website/src/styles" as *;

  button.secondary {
    max-width: 600px;
    margin: 40px 0;
  }

  .menu-container {
    position: absolute;
    top: 0;
    width: 100%;
    height: 300vh;
    background-color: $black;
    opacity: 1;
    z-index: 10;
  }

  .connexion {
    margin: 40px auto;
    width: 100%;
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    row-gap: 20px;
  }

  .menu-nav-container {
    margin: 80px auto 0;
    width: 1200px;
    max-width: 100%;
    height: calc(100vh - 200px);
    display: flex;
    flex-direction: column;
    justify-content: flex-start;
    align-items: center;
  }

  .discord {
    margin-right: 20px;
  }

  .social-icons {
    display: flex;
    flex-direction: row;
    align-items: center;
  }

  @media (max-width: 980px) {
    .container {
      padding-top: 20px;
    }
  }
</style>
