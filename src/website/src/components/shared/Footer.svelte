<script lang="ts">
  import { Link } from "svelte-routing";
  import Logo from "@icons/Logo.svelte";
  import Discord from "@icons/Discord.svelte";
  import Twitter from "@icons/Twitter.svelte";
  import FooterNav from "./FooterNav.svelte";
  import Badge from "@icons/Badge.svelte";
</script>

<footer>
  <div class="container">
    <div class="top">
      <Logo />
      <div class="social">
        <a class="discord" href="https://discord.gg/9DjDzf38WR" target="_blank">
          <Discord />
        </a>
        <a href="https://twitter.com/ICPSquadNFT" target="_blank">
          <Twitter />
        </a>
      </div>
    </div>
    <FooterNav />
  </div>
  <div class="sub-nav">
    <div class="container">
      © {new Date().getFullYear()} Dfinity community
      <div class="badge">
        <a href="https://dfinity.org/" target="_blank">
          <Badge />
        </a>
      </div>
      <Link to="/privacy">
        <div class="privacy">Privacy Policy</div>
      </Link>
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

  .sub-nav {
    background-color: $verydarkgrey;
    .container {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 30px 20px;
      .privacy {
        color: $white;
      }
    }
  }
</style>
