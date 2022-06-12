<script lang="ts">
  export let supply: number | null = null;
  export let floorPrice: number | null = null;
</script>

<div class="info-box">
  <div class="supply">
    <div class="title">Supply</div>
    <div class="value">
      {supply ? supply : "0"}
    </div>
  </div>
  <div class="floorPrice">
    <div class="title">Floor price (ICP)</div>
    <div class="value">
      {floorPrice ? floorPrice : "-"}
    </div>
  </div>
</div>

<style lang="scss">
  @use "./src/website/src/styles" as *;

  .info-box {
    display: flex;
    flex-direction: row;
    justify-content: space-between;
    align-items: center;
    padding: 10px;
    border-radius: 5px;
    background-color: $verydarkgrey;
  }

  .info-box .title {
    font-size: 14px;
    font-weight: bold;
    color: var(--page-feature-color);
  }

  .info-box .value {
    font-size: 16px;
    font-weight: bold;
    color: $white;
  }
</style>
