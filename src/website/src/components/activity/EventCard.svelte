<script lang="ts">
  import type { ExtendedEvent } from "@canisters/hub/hub.did.d";
  export let operation: string;
  export let collection: string;
  export let unix_time: bigint;

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
    <img src={`./assets/icons_activity/${operation}.svg`} alt="Activity icon" />
  </div>
  <div class="operation">{capitalizeString(operation)}</div>
  <div class="collection">{collection}</div>
  <div class="date">{unixTimeToLocalDate(unix_time)} - {unixTimeToLocalTime(unix_time)}</div>
</div>

<style lang="scss">
  @use "../../styles" as *;
  .grid-row {
    width: 100%;
    display: grid;
    grid-template-columns: 80px 1fr 1fr 1fr;
    padding: 10px 20px;
    align-items: center;
    background-color: $verydarkgrey;
    border-radius: 10px;
    margin-bottom: 5px;
  }

  .carat {
    cursor: pointer;
    display: none;
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

  img {
    width: 50px;
    height: 50px;
    border-radius: 10px;
  }
</style>
