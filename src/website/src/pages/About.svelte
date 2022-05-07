<script lang="ts">
  import Header from "@components/shared/Header.svelte";
  import Footer from "@components/shared/Footer.svelte";
  import Join from "@components/shared/Join.svelte";
  import Newsletter from "@components/shared/Newsletter.svelte";
</script>

<Header />
<div class="page-header">
  <h1>About Us</h1>
</div>
<div class="container" />
<Join />
<Newsletter />
<Footer />

<style lang="scss">
  @use "../styles" as *;

  main,
  h1 {
    --page-feature-color: #{$blue};
  }
</style>
