<script lang="ts">
  import Header from "@components/shared/Header.svelte";
  import Footer from "@components/shared/Footer.svelte";
  import Join from "@components/shared/Join.svelte";
  import Newsletter from "@components/shared/Newsletter.svelte";
  import MissionCard from "@components/mission/MissionCard.svelte";
</script>

<Header />
<div class="page-header">
  <h1>Mission</h1>
</div>
<div class="mission-container">
  <!-- {#each missions as mission}
    <MissionCard title={mission.title} description={mission.description} image={mission.image} />
  {/each} -->
  <MissionCard />
  <!-- <MissionCard />
  <MissionCard /> -->
</div>
<Join />
<Newsletter />
<Footer />

<style lang="scss">
  @use "../styles" as *;

  h1 {
    --page-feature-color: #{$green};
  }

  .mission-container {
    display: grid;
    grid-template-columns: 1fr 1fr 1fr;
    grid-gap: 20px;
    margin: 60px 60px;
  }
</style>
