<script lang="ts">
  import Header from "@components/shared/Header.svelte";
  import Footer from "@components/shared/Footer.svelte";
  import Join from "@components/shared/Join.svelte";
  import Newsletter from "@components/shared/Newsletter.svelte";
  import LegendaryAvatar from "@src/components/shared/LegendaryAvatar.svelte";
  import PartnershipsForm from "@src/components/partnerships/PartnershipsForm.svelte";
  import Link from "@src/components/shared/LinkButton.svelte";
</script>

<Header />
<div class="page-header">
  <h1>Leaderboard</h1>
</div>
<div class="container skinny">
  <div class="stats-container">
    <div>
      <div class="stat">20 June 22</div>
      <div class="label">START DATE</div>
    </div>
    <div>
      <div class="stat">30 July 22</div>
      <div class="label">END DATE</div>
    </div>
    <div>
      <div class="stat">86 ICP</div>
      <div class="label">ESTIMATED REWARDS</div>
    </div>
  </div>
  <button class="secondary"> CONNECT WALLET TO SEE YOUR RANK </button>
  <div class="grid-header">
    <div class="header-rank">RANK</div>
    <div class="header-points">POINTS</div>
  </div>
  <div class="grid-row">
    <div class="rank">1</div>
    <div class="avatar">
      <img
        src="https://jmuqr-yqaaa-aaaaj-qaicq-cai.raw.ic0.app/?type=thumbnail&tokenid=jgmq2-sykor-uwiaa-aaaaa-cmaca-uaqca-aabxe-a"
        alt="ICP Squad Avatar"
      />
    </div>
    <div class="name">andrewsel</div>
    <div class="points">180</div>
  </div>
</div>
<Footer />

<style lang="scss">
  @use "../styles" as *;

  h1,
  h3,
  a,
  button {
    --page-feature-color: #{$green};
  }

  .container {
    display: flex;
    flex-direction: column;
    align-items: center;
    padding-bottom: 100px;
    &.skinny {
      max-width: 1000px;
      margin-bottom: 0;
    }
  }

  button {
    max-width: 100%;
    margin: 40px 0;
  }

  .stats-container {
    width: 100%;
    background-color: $verydarkgrey;
    padding: 30px;
    border-radius: 10px;
    display: grid;
    grid-template-columns: 1fr 1fr 1fr;
  }

  .stat,
  .label {
    text-align: center;
  }

  .stat {
    font-size: 30px;
    font-weight: bold;
  }

  .grid-row,
  .grid-header {
    width: 100%;
    display: grid;
    grid-template-columns: 60px 40px 1fr 60px;
    padding: 10px 20px;
    align-items: center;
  }

  .grid-row {
    background-color: $verydarkgrey;
    border-radius: 10px;
  }

  .header-rank {
    grid-column: span 3;
  }

  .name {
    padding-left: 20px;
  }

  .avatar > img {
    border-radius: 50%;
  }

  .points,
  .header-points {
    text-align: right;
  }
</style>
