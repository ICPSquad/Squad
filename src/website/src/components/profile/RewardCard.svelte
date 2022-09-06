<script lang="ts">
  import type { Reward } from "@canisters/accessories/accessories.did";
  import Carat from "@icons/Carat.svelte";
  import { getCanisterInfo } from "@psychedelic/dab-js";

  export let reward: Reward;
  let open: boolean = false;
  let name: string = rewardToCollection(reward);

  function unixTimeToDate(unixTime: number): string {
    // Convert nanoseconds to milliseconds
    const date = new Date(unixTime / 1000 / 1000);
    return date.toLocaleDateString();
  }

  function rewardToType(reward: Reward): string {
    let keys = Object.keys(reward.category);
    console.log("keys", keys);
    switch (keys[0]) {
      case "NFT":
        return "NFT";
      case "Token":
        return "Token";
      case "Material":
        return "Material";
      default:
        return "Unknown";
    }
  }

  function rewardToCollection(reward: Reward): string {
    let canisterId = reward.collection.toString();
    // ICP Ledger
    if (canisterId === "ryjl3-tyaaa-aaaaa-aaaba-cai") {
      return "ICP Ledger";
    }
    // Accessories
    if (canisterId === "po6n2-uiaaa-aaaaj-qaiua-cai") {
      return "dSquad";
    }
    updateName();
    return "...";
  }

  function rewardToAmount(reward: Reward): number {
    let canisterId = reward.collection.toString();
    let amount = Number(reward.amount);
    // ICP Ledger
    if (canisterId === "ryjl3-tyaaa-aaaaa-aaaba-cai") {
      return amount / 10 ** 8;
    }
    return amount;
  }

  async function updateName() {
    if (name !== "dSquad" && name !== "ICP Ledger") {
      const canisterId = reward.collection.toString();
      const metadata = await getCanisterInfo({ canisterId });
      if (metadata) {
        name = metadata.name;
      }
    }
  }
</script>

<div class="grid-row">
  <div class="icon">
    <img src="arun-logo.jpeg" alt="" />
  </div>
  <div class="type hide-on-mobile">{rewardToType(reward)}</div>
  <div class="collection hide-on-mobile">{rewardToCollection(reward)}</div>
  <div class="amount hide-on-mobile">{rewardToAmount(reward)}</div>
  <div class="date">{unixTimeToDate(Number(reward.date))}</div>
  <div on:click={() => (open = !open)} class="carat show-on-mobile">
    <Carat rotate={open ? -90 : 90} />
  </div>
</div>
{#if open}
  <div class="details">
    <div class="collection">{rewardToCollection(reward)}</div>
    <div class="amount">{rewardToAmount(reward)}</div>
  </div>
{/if}

<style lang="scss">
  @use "../../styles" as *;
  .grid-row {
    width: 100%;
    display: grid;
    grid-template-columns: 80px 1fr 1fr 1fr 120px;
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
    border-radius: 50%;
  }
  @media (max-width: 768px) {
    .grid-row {
      grid-template-columns: 1fr 120px 1fr;
      font-size: small;
    }

    .hide-on-mobile {
      display: none;
    }

    .carat {
      display: flex;
      justify-content: center;
    }
  }
</style>
