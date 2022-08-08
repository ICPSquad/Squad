<script lang="ts">
  import RewardCard from "./RewardCard.svelte";
  import type { Reward } from "@canisters/accessories/accessories.did.d";
  export let received_rewards: [Array<Reward>] | [];

  function typeObjectToString(): string {}
</script>

{#if received_rewards.length > 0}
  <h2>Received airdrop</h2>
  <div class="title">
    <div class="name">Name</div>
    <div class="collection">Collection</div>
    <div class="url">URL</div>
    <div class="time">Date</div>
  </div>
  {#each received_rewards[0] as reward}
    <RewardCard name={reward.name} collection={reward.collection.toString()} url={`https://${reward.collection.toString()}.raw.ic0.app/?&tokenid=${reward.identifier[0]}`} time={Number(reward.date)} />
  {/each}
{:else}
  <h2>You have not received any airdrop</h2>
{/if}

<style lang="scss">
  @use "../../styles" as *;

  h2 {
    text-align: center;
    color: $yellow;
  }

  .title {
    display: grid;
    grid-template-columns: 1fr 1fr 1fr 120px;
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
</style>
