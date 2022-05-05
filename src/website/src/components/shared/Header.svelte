<script lang="ts">
  import { Link } from "svelte-routing";
  import Logo from "@icons/Logo.svelte";
  import Menu from "@icons/Menu.svelte";
  import { user } from "@src/store/user";
  import { plugConnection } from "@utils/connection";

  let connected: boolean = false;
</script>

<nav class="container">
  <Link to="/">
    <Logo />
  </Link>
  <div class="right">
    <button on:click={plugConnection}> {$user.loggedIn ? "You are connected" : "Connect your wallet"} </button>
    <Menu />
  </div>
</nav>

<style lang="scss">
  @use "./src/website/src/styles" as *;

  nav {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding-top: 30px;
    padding-bottom: 30px;
  }

  .right {
    display: flex;
    align-items: center;
  }

  button {
    border: 3px solid $pink;
    background-color: transparent;
    border-radius: 40px;
    margin-right: 20px;
    font-size: 1rem;
  }
</style>
