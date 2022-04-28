<script>
  import { Link } from "svelte-routing";
  import Logo from "../../assets/Logo.svelte";
  import Menu from "../../assets/icons/Menu.svelte";
</script>

<nav class="container">
  <Link to="/">
    <Logo />
  </Link>
  <div class="right">
    <button> Connect Wallet </button>
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
