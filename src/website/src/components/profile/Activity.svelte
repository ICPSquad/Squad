<script lang="ts">
  import type { Activity } from "@canisters/hub/hub.did.d";
  import { e8sToICP } from "@utils/stats";
  export let activity: Activity;
</script>

<h2>Cumulative activity</h2>
<div>
  <div class="field">
    <div class="label">Trade (number of events)</div>
    <div class="value">{Number(activity.buy[0]) + Number(activity.sell[0])} events</div>
  </div>
  <div class="field">
    <div class="label">Trade (amount of ICP)</div>
    <div class="value">{e8sToICP([activity.buy[1] + activity.sell[1]])} ICPs</div>
  </div>
  <div class="field">
    <div class="label">Mint (number of events)</div>
    <div class="value">{Number(activity.mint)} events</div>
  </div>
  <div class="field">
    <div class="label">Burn (number of events)</div>
    <div class="value">{Number(activity.burn)} events</div>
  </div>
  <div class="field">
    <div class="label">Accessory burned</div>
    <div class="value">{Number(activity.accessory_burned)}</div>
  </div>
  <div class="field">
    <div class="label">Accessory created</div>
    <div class="value">{Number(activity.accessory_minted)}</div>
  </div>
  <div class="field">
    <div class="label">Involved collection</div>
    <div class="value">{Number(activity.collection_involved)}</div>
  </div>
</div>

<style lang="scss">
  @use "../../styles" as *;

  h2 {
    text-align: center;
    color: $yellow;
  }

  .field {
    margin-bottom: 30px;
  }
  .label {
    margin-bottom: 4px;
  }

  .value {
    font-weight: bold;
    font-size: 30px;
    &.small {
      font-size: 14px;
    }
  }
  @media (max-width: 800px) {
    .value {
      font-size: 14px;
    }
  }
</style>
