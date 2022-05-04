<script lang="ts">
  import Header from "@components/shared/Header.svelte";
  import Footer from "@components/shared/Footer.svelte";
  import HeroSection from "@components/home/HeroSection.svelte";
  import Create from "@components/home/Create.svelte";
  import CollectOrTrade from "@components/home/CollectOrTrade.svelte";
  import Join from "@components/shared/Join.svelte";
  import Newsletter from "@components/shared/Newsletter.svelte";
  import EngageAndEarn from "@components/home/EngageAndEarn.svelte";
</script>

<div class="background">
  <Header />
  <HeroSection />
</div>
<Create />
<EngageAndEarn />
<CollectOrTrade />
<Join />
<Newsletter />
<Footer />

<style lang="scss">
  .background {
    background-image: url("/assets/home-hero-background.png");
    background-size: cover;
    background-repeat: no-repeat;
  }
</style>
