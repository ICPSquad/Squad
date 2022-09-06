<script lang="ts">
  import Carat from "@icons/Carat.svelte";
  export let name: string | null;
  export let reward: number | null;
  export let time: number | null;
  let open: boolean = false;

  function unixTimeToDate(unixTime: number): string {
    // Convert nanoseconds to milliseconds
    const date = new Date(unixTime / 1000 / 1000);
    return date.toLocaleDateString();
  }
</script>

<div class="grid-row">
  <div class="name">{name}</div>
  <div class="reward hide-on-mobile">{reward} points</div>
  <div class="time">{unixTimeToDate(time)}</div>
  <div on:click={() => (open = !open)} class="carat show-on-mobile">
    <Carat rotate={open ? -90 : 90} />
  </div>
</div>
{#if open}
  <div class="details">
    <div class="reward ">{reward} points</div>
  </div>
{/if}

<style lang="scss">
  @use "../../styles" as *;
  .grid-row {
    width: 100%;
    display: grid;
    grid-template-columns: 1fr 1fr 120px;
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

  @media (max-width: 768px) {
    .grid-row {
      grid-template-columns: 1fr 1fr 20px;
      font-size: small;
    }

    .hide-on-mobile {
      display: none;
    }

    .carat {
      display: flex;
      justify-content: right;
    }
  }
</style>
