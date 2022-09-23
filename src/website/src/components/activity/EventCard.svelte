<script lang="ts">
  import type { ExtendedEvent } from "@canisters/hub/hub.did.d";
  import Carat from "@icons/Carat.svelte";
  import ActivityDetails from "./ActivityDetails.svelte";
  import { _getNameOpt, _getFromOpt, _getToOpt, _getPriceOpt, _getTokenIdOpt } from "@utils/event";

  export let collection: string;
  export let event: ExtendedEvent;

  let open: Boolean = false;

  function unixTimeToLocalTime(unix_time: bigint): string {
    let date = new Date(Number(unix_time));
    return date.toLocaleTimeString();
  }

  function unixTimeToLocalDate(unix_time: bigint): string {
    let date = new Date(Number(unix_time));
    return date.toLocaleDateString();
  }

  function capitalizeString(str: string): string {
    return str.charAt(0).toUpperCase() + str.slice(1);
  }
</script>

<div class="grid-row">
  <div class="icon">
    <img src={`./assets/icons_activity/${event.operation}.svg`} alt="Activity icon" />
  </div>
  <div class="operation">{capitalizeString(event.operation)}</div>
  <div class="collection">{collection}</div>
  <div class="date hide-on-mobile">
    {unixTimeToLocalDate(event.time)} - {unixTimeToLocalTime(event.time)}
  </div>
  <div on:click={() => (open = !open)} class="details-header">
    <Carat rotate={open ? -90 : 90} />
  </div>
</div>
{#if open}
  <ActivityDetails operation={event.operation} tokenIdentifier={_getTokenIdOpt(event)} name={_getNameOpt(event)} from={_getFromOpt(event)} to={_getToOpt(event)} price={_getPriceOpt(event)} />
{/if}

<style lang="scss">
  @use "../../styles" as *;
  .grid-row {
    width: 100%;
    display: grid;
    grid-template-columns: 80px 1fr 1fr 1fr 20px;
    padding: 10px 20px;
    align-items: center;
    background-color: $verydarkgrey;
    border-radius: 10px;
    margin-bottom: 5px;
  }

  img {
    width: 50px;
    height: 50px;
    border-radius: 10px;
  }

  .details-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    cursor: pointer;
  }

  @media (max-width: 768px) {
    .grid-row {
      grid-template-columns: 80px 1fr 1fr 20px;
      font-size: small;
    }

    .hide-on-mobile {
      display: none;
    }
  }
</style>
