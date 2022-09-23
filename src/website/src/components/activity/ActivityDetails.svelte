<script lang="ts">
  import type { TokenIdentifier } from "@canisters/accessories/accessories.did.d";

  export let operation: string;

  // All events
  export let tokenIdentifier: TokenIdentifier | null = null;

  // dSquad only
  export let name: string | null = null;

  // Sale only
  export let from: string | null = null;
  export let to: string | null = null;
  export let price: number | null = null;
</script>

<div class="details">
  {#if tokenIdentifier}
    <div class="detail">
      <div class="detail__title">Token</div>
      <div class="detail__value">{tokenIdentifier}</div>
    </div>
  {/if}
  {#if name}
    <div class="detail">
      <div class="detail__title">Name</div>
      <div class="detail__value">{name}</div>
    </div>
  {/if}
  {#if from && operation === "sale"}
    <div class="detail">
      <div class="detail__title">From</div>
      <div class="detail__value">{from}</div>
    </div>
  {/if}
  {#if to && operation === "sale"}
    <div class="detail">
      <div class="detail__title">To</div>
      <div class="detail__value">{to}</div>
    </div>
  {/if}
  {#if price && operation === "sale"}
    <div class="detail">
      <div class="detail__title">Price</div>
      <div class="detail__value">{price} ICPs</div>
    </div>
  {/if}
</div>

<style lang="scss">
  @use "../../styles" as *;

  .details {
    display: flex;
    flex-direction: column;
    gap: 1rem;
    margin-top: 1rem;
    width: 100%;
    background-color: $verydarkgrey;
    margin-top: 10px;
    margin-bottom: 20px;
    padding: 10px 20px;
    border-radius: 10px;
  }

  .detail {
    display: flex;
    flex-direction: row;
    gap: 2rem;
  }

  .detail__title {
    font-weight: 600;
    font-size: 1.2rem;
    width: 20%;
  }

  .detail__value {
    width: 80%;
  }

  @media (max-width: 768px) {
    .detail__value {
      word-wrap: break-word;
      white-space: pre-wrap;
      word-break: break-word;
    }
  }
</style>
