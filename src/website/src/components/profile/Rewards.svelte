<script lang="ts">
  import RewardCard from "./RewardCard.svelte";
  import type { Reward } from "@canisters/accessories/accessories.did.d";
  export let received_rewards: [Array<Reward>] | [];

  $: rewards = received_rewards[0].sort((a, b) => {
    return Number(b.date) - Number(a.date);
  });
</script>

{#if rewards.length > 0}
  <h2>Received airdrop</h2>
  <div class="title">
    <div class="reward" />
    <div class="type hide-on-mobile">Type</div>
    <div class="collection hide-on-mobile">Collection</div>
    <div class="amount hide-on-mobile">Amount</div>
    <div class="time">Date</div>
  </div>
  {#each rewards as reward}
    <RewardCard {reward} />
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
    grid-template-columns: 80px 1fr 1fr 1fr 120px;
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
    .hide-on-mobile {
      display: none;
    }

    .title {
      grid-template-columns: 1fr 1fr 1fr;
    }
  }
</style>
