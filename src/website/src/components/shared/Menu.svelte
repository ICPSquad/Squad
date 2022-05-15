<script lang="ts">
  import Discord from "@src/icons/Discord.svelte";
  import Twitter from "@src/icons/Twitter.svelte";
  import FooterNav from "./FooterNav.svelte";

  export let closeMenu;
</script>

<div class="menu-container">
  <div class="container menu-nav-container">
    <FooterNav textAlignCenter {closeMenu} />
    <button class="secondary"> Disconnect Wallet </button>
    <div class="social-icons">
      <a class="discord" href="https://discord.gg/SqtQ3UJR" target="_blank">
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

  .menu-nav-container {
    margin: 140px auto 0;
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
</style>
