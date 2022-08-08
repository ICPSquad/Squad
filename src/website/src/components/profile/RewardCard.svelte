<script lang="ts">
  export let name: string | null;
  export let collection: string | null;
  export let url: string | null;
  export let time: number | null;

  function unixTimeToDate(unixTime: number): string {
    // Convert nanoseconds to milliseconds
    const date = new Date(unixTime / 1000 / 1000);
    return date.toLocaleDateString();
  }
</script>

<div class="grid-row">
  <div class="name">{name}</div>
  <div class="collection"><a href={`https://test.icscan.io/canister/${collection}`} target="_blank"> {collection} </a></div>
  <div><a href={url} target="_blank"> Look </a></div>
  <div class="date">{unixTimeToDate(time)}</div>
</div>

<style lang="scss">
  @use "../../styles" as *;
  .grid-row {
    width: 100%;
    display: grid;
    grid-template-columns: 1fr 1fr 1fr 120px;
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
</style>
