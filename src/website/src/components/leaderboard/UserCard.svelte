<script lang="ts">
  import Carat from "@icons/Carat.svelte";
  import type { TokenIdentifier } from "@canisters/avatar/avatar.did.d";

  export let rank: Number = 0;
  export let tokenIdentifier: TokenIdentifier = "";
  export let name: String | undefined;
  export let style_score: Number = 0;
  export let engagement_score: Number = 0;
  export let total_score: Number = 0;

  let open: Boolean = false;
</script>

<div class="grid-row">
  <div class="rank">{rank}</div>
  <div class="avatar">
    <a href={`https://jmuqr-yqaaa-aaaaj-qaicq-cai.raw.ic0.app/?type=thumbnail&tokenid=${tokenIdentifier}`} target="_blank">
      {#if tokenIdentifier.length > 0}
        <img src={`https://jmuqr-yqaaa-aaaaj-qaicq-cai.raw.ic0.app/tokenid=${tokenIdentifier}`} alt="Avatar" />
      {/if}
    </a>
  </div>
  <div class="name">{name}</div>
  <div class="points">
    <div>{total_score}</div>
    <div on:click={() => (open = !open)} class="details-header">
      <Carat rotate={open ? -90 : 90} />
    </div>
  </div>
</div>
{#if open}
  <div class="details">
    <div class="style-score">Style score : {style_score}</div>
    <div class="engagement-score">Engagement score : {engagement_score}</div>
  </div>
{/if}

<style lang="scss">
  @use "../../styles" as *;

  .grid-row {
    width: 100%;
    display: grid;
    grid-template-columns: 60px 150px 1fr 60px;
    grid-template-rows: 140px;
    align-items: center;
    background-color: $verydarkgrey;
    border-radius: 10px;
    margin-bottom: 10px;
  }
  @media (max-width: 768px) {
    .grid-row {
      padding: 10px 10px;
      grid-template-columns: 20px 150px 1fr 25px;
    }

    .name {
      display: flex;
      align-items: center;
      flex-wrap: wrap;
      word-break: break-all;
      text-overflow: ellipsis;
      overflow: hidden;
      height: 150px;
      word-wrap: wrap;
      font-size: small;
      padding: 10px;
    }

    .rank {
      font-size: x-small;
    }
  }

  @media (max-width: 320px) {
    .name {
      visibility: hidden;
    }
  }

  .details-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    cursor: pointer;
  }
  .name {
    padding-left: 10px;
  }

  .avatar {
    padding: 0px 10px;
  }
  .avatar > a > img {
    border-radius: 5%;
  }

  .rank {
    font-size: 20px;
    font-weight: bold;
    display: flex;
    height: 100%;
    align-items: center;
    justify-content: center;
  }
  .points {
    display: flex;
    height: 100%;
    flex-direction: column;
    align-items: center;
    justify-content: space-around;
    font-size: 20px;
    font-weight: bold;
  }

  .points,
  .header-points {
    text-align: right;
  }

  .pagination {
    margin-top: 20px;
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
</style>
