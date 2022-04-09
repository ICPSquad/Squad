<script>
  import Header from "../components/Header.svelte";
  import Footer from "../components/Footer.svelte";
</script>

<Header />
<main>
  <h1>Create Avatar</h1>

  <p>
    test a
    <a href="#">link</a>
  </p>
</main>
<Footer />

<style lang="scss">
  @use "./src/styles" as *;

  main {
    --page-feature-color: #{$yellow};
  }
</style>
