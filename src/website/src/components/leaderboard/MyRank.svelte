<script lang="ts">
  import type { Leaderboard } from "@canisters/hub/hub.did.d";
  import type { Principal } from "@dfinity/principal";
  import { plugConnection } from "@src/utils/connection";
  import { user } from "@src/store/user";
  export let leaderboard: Leaderboard | undefined;
  let my_principal: Principal | undefined;

  user.subscribe(async (user) => {
    if (user.principal) {
      my_principal = user.principal;
    }
  });

  $: my_index = leaderboard ? leaderboard.findIndex((info) => info[0].toText() === my_principal.toText()) : -1;
</script>

{#if $user.loggedIn && my_index > -1}
  <div class="grid-row">
    <div class="rank">{my_index + 1}</div>
    <div class="avatar">
      <a href={`https://jmuqr-yqaaa-aaaaj-qaicq-cai.raw.ic0.app/?type=thumbnail&tokenid=${leaderboard[my_index][2]}`} target="_blank">
        <img src={`https://jmuqr-yqaaa-aaaaj-qaicq-cai.raw.ic0.app/tokenid=${leaderboard[my_index][2]}`} alt="Avatar" />
      </a>
    </div>
    <div class="name">{leaderboard[my_index][1].length > 0 ? leaderboard[my_index] : leaderboard[my_index][0].toText()}</div>
    <div class="points">{Number(leaderboard[my_index][5])}</div>
  </div>
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
</style>
