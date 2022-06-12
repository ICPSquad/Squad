<script lang="ts">
  import Header from "@components/shared/Header.svelte";
  import Footer from "@components/shared/Footer.svelte";
  import UserCard from "@src/components/leaderboard/UserCard.svelte";
  import type { Leaderboard } from "@canisters/hub/hub.did.d";
  import { hubActor } from "@src/api/actor";
  import { paginate, DarkPaginationNav } from "svelte-paginate";
  import MyRank from "@components/leaderboard/MyRank.svelte";

  let currentPage = 1;
  let pageSize = 100;
  let open = false;

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
      <UserCard
        rank={(currentPage - 1) * 100 + (i + 1)}
        tokenIdentifier={info[2]}
        name={info[1].length > 0 ? info[1] : info[0].toText()}
        total_score={Number(info[5])}
        style_score={Number(info[3])}
        engagement_score={Number(info[4])}
      />
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
    display: flex;

    flex-direction: column;
    align-items: center;
    justify-content: space-around;
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
