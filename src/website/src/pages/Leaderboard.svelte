<script lang="ts">
  import Header from "@components/shared/Header.svelte";
  import Footer from "@components/shared/Footer.svelte";
  import type { Leaderboard } from "@canisters/hub/hub.did.d";
  import { hubActor } from "@src/api/actor";
  import { paginate, DarkPaginationNav } from "svelte-paginate";
  import MyRank from "@components/leaderboard/MyRank.svelte";

  let currentPage = 1;
  let pageSize = 100;
  let leaderboard: Leaderboard | undefined | null;
  $: paginatedLeaderboard = leaderboard ? paginate({ items: leaderboard, pageSize, currentPage }) : [];
  let hub_actor = hubActor();

  async function getLeaderboard() {
    let data = await hub_actor.get_leaderboard();
    console.log(data);
    if (data.length > 0) {
      leaderboard = data[0];
    } else {
      leaderboard = null;
    }
  }
  getLeaderboard();
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
  <div class="my-rank">
    <MyRank {leaderboard} />
  </div>
  <div class="grid-header">
    <div class="header-rank">RANK</div>
    <div class="header-points">POINTS</div>
  </div>
  {#if leaderboard}
    {#each paginatedLeaderboard as info, i}
      <div class="grid-row">
        <div class="rank">{(currentPage - 1) * 100 + (i + 1)}</div>
        <div class="avatar">
          <a href={`https://jmuqr-yqaaa-aaaaj-qaicq-cai.raw.ic0.app/?type=thumbnail&tokenid=${info[2]}`} target="_blank">
            <img src={`https://jmuqr-yqaaa-aaaaj-qaicq-cai.raw.ic0.app/tokenid=${info[2]}`} alt="Avatar" />
          </a>
        </div>
        <div class="name">{info[1].length > 0 ? info[1] : info[0].toText()}</div>
        <div class="points">{Number(info[5])}</div>
      </div>
    {/each}
    <DarkPaginationNav class="pagination" totalItems={leaderboard.length} {pageSize} {currentPage} limit={1} showStepOptions={true} on:setPage={(e) => (currentPage = e.detail.page)} />
  {/if}
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
    grid-template-columns: 60px 120px 1fr 60px;
    padding: 10px 20px;
    align-items: center;
  }

  .grid-row {
    background-color: $verydarkgrey;
    border-radius: 10px;
    margin-bottom: 5px;
  }

  .header-rank {
    grid-column: span 3;
  }

  .name {
    padding-left: 20px;
  }

  .avatar > a > img {
    border-radius: 50%;
  }

  .rank {
    font-size: 20px;
    font-weight: bold;
  }
  .points {
    font-size: 20px;
    font-weight: bold;
  }

  .points,
  .header-points {
    text-align: right;
  }

  .pagination {
    margin-top: 20px;
  }

  .my-rank {
    width: 100%;
    margin: 20px auto;
    display: flex;
    flex-direction: row;
    justify-content: center;
  }
</style>
