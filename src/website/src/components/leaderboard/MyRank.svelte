<script lang="ts">
  import type { Leaderboard } from "@canisters/hub/hub.did.d";
  import type { Principal } from "@dfinity/principal";
  import { plugConnection } from "@src/utils/connection";
  import { user } from "@src/store/user";
  import Carat from "@icons/Carat.svelte";

  export let leaderboard: Leaderboard | undefined;
  let my_principal: Principal | undefined;

  user.subscribe(async (user) => {
    if (user.principal) {
      my_principal = user.principal;
    }
  });

  $: my_index = leaderboard ? leaderboard.findIndex((info) => info[0].toText() === my_principal.toText()) : -1;

  $: style_score = my_index > -1 ? Number(leaderboard[my_index][3]) : 0;
  $: engagement_score = my_index > -1 ? Number(leaderboard[my_index][4]) : 0;

  $: realRanks = createRealRanks(leaderboard);

  function createRealRanks(leaderboard: Leaderboard): Number[] {
    if (!leaderboard) return [];
    let realRank = [];
    let rank = 1;
    let lastScore = Number(leaderboard[0][5]);
    for (let i = 0; i < leaderboard.length; i++) {
      if (Number(leaderboard[i][5]) != lastScore) {
        rank++;
        realRank.push(rank);
      } else {
        realRank.push(rank);
      }
      lastScore = Number(leaderboard[i][5]);
    }
    return realRank;
  }

  let open: Boolean = false;
</script>

{#if $user.loggedIn && my_index > -1}
  <div class="grid-row">
    <div class="rank">{realRanks[my_index]}</div>
    <div class="avatar">
      <a href={`https://jmuqr-yqaaa-aaaaj-qaicq-cai.raw.ic0.app/?type=thumbnail&tokenid=${leaderboard[my_index][2]}`} target="_blank">
        <img src={`https://jmuqr-yqaaa-aaaaj-qaicq-cai.raw.ic0.app/tokenid=${leaderboard[my_index][2]}`} alt="Avatar" />
      </a>
    </div>
    <div class="name">{leaderboard[my_index][1].length > 0 ? leaderboard[my_index][1] : leaderboard[my_index][0].toText()}</div>
    <div class="points">
      {Number(leaderboard[my_index][5])}
      <div on:click={() => (open = !open)} class="details-header">
        <Carat rotate={open ? -90 : 90} />
      </div>
    </div>
  </div>
  {#if open}
    <div class="details">
      <div class="style-score">Style score : {style_score}</div>
      <div class="engagement-score">Engagement score : {engagement_score}</div>
    </div>
  {/if}
{:else}
  <button class="secondary" on:click={() => plugConnection()}> SIGN IN TO SEE YOUR RANK </button>
{/if}

<style lang="scss">
  @use "../../styles" as *;

  .grid-row {
    width: 100%;
    display: grid;
    grid-template-columns: 60px 120px 1fr 60px;
    padding: 10px 20px;
    align-items: center;
    background-color: $verydarkgrey;
    border-radius: 10px;
    margin-bottom: 5px;
  }

  @media (max-width: 768px) {
    .grid-row {
      grid-template-columns: 40px 60px 1fr 40px;
      font-size: small;
    }
  }

  .header-rank {
    grid-column: span 3;
  }
  .header-points {
    text-align: right;
  }
  .grid-row {
    background-color: $verydarkgrey;
    border-radius: 10px;
    margin-bottom: 5px;
  }
  .avatar > a > img {
    border-radius: 50%;
  }
  .name {
    padding-left: 20px;
  }

  .points {
    font-size: 20px;
    font-weight: bold;
    text-align: right;
  }

  .rank {
    font-size: 20px;
    font-weight: bold;
  }

  .points {
    display: flex;
    height: 100%;
    flex-direction: column;
    align-items: center;
    justify-content: space-around;
    font-size: 20px;
    font-weight: bold;
  }

  .details-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    cursor: pointer;
  }

  .details {
    width: 100%;
    display: flex;
    flex-direction: row;
    justify-content: space-around;
    align-items: center;
    background-color: $verydarkgrey;
    margin-top: 10px;
    margin-bottom: 20px;
    padding: 10px 20px;
    border-radius: 10px;
  }
</style>
