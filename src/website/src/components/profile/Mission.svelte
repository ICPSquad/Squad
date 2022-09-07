<script lang="ts">
  import MissionCard from "./MissionCard.svelte";
  import type { Mission } from "@canisters/hub/hub.did.d";
  import LinkButton from "../shared/LinkButton.svelte";
  export let completed: [Mission, bigint][];
</script>

{#if completed && completed.length > 0}
  <h2>Completed missions</h2>
  <div class="title">
    <div class="name">Name</div>
    <div class="reward">Reward</div>
    <div class="time">Date</div>
  </div>
  {#each completed as [mission, time]}
    <MissionCard name={mission.title} reward={Number(mission.points)} time={Number(time)} />
  {/each}
{:else}
  <h2>You have not completed any mission yet.</h2>
  <LinkButton to="/mission">
    <button> Mission </button>
  </LinkButton>
{/if}

<style lang="scss">
  @use "../../styles" as *;

  h2 {
    text-align: center;
    color: $yellow;
  }

  .title {
    display: grid;
    grid-template-columns: 1fr 1fr 120px;
    padding: 10px 20px;
    align-items: center;
    font-size: large;
    font-weight: bold;
  }

  .header-name,
  .header-reward,
  .header-time {
    font-size: large;
    font-weight: bold;
  }

  @media (max-width: 768px) {
    .title {
      grid-template-columns: 1fr 1fr 20px;
      font-size: small;
    }
  }
</style>
