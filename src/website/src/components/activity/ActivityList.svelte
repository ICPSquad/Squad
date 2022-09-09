<script lang="ts">
  import { NFTRegistry } from "@psychedelic/dab-js";
  import EventCard from "./EventCard.svelte";
  import type { Principal } from "@dfinity/principal";
  import type { ExtendedEvent } from "@canisters/hub/hub.did.d";
  import type { FormattedMetadata } from "@psychedelic/dab-js/dist/utils/registry";

  let informations: FormattedMetadata[] | null = null;
  let registry: NFTRegistry = new NFTRegistry();

  async function updateInformations() {
    let result = await registry.getAll();
    informations = result;
  }

  function principalToName(p: Principal): string {
    if (p.toText() === "po6n2-uiaaa-aaaaj-qaiua-cai") {
      return "dSquad";
    }

    if (!informations) {
      return "..";
    } else {
      let info = informations.find((i) => i.principal_id.toText() === p.toText());
      if (info) {
        return info.name;
      } else {
        return p.toText();
      }
    }
  }

  export let extended_events: Array<ExtendedEvent>;

  updateInformations();
</script>

{#if extended_events && extended_events.length > 0 && informations}
  <div class="container">
    <div class="summary-board">
      <div class="board">
        <h4>Interacted collections</h4>
        <div class="value">{3}</div>
      </div>
      <div class="board">
        <h4>Burned accessories</h4>
        <div class="value">{20}</div>
      </div>
      <div class="board">
        <h4>Minted accessories</h4>
        <div class="value">{0}</div>
      </div>
    </div>

    <div class="title">
      <div />
      <div class="event">Event</div>
      <div class="collection">Collection</div>
      <div class="date ">Date</div>
    </div>
    {#each extended_events as event}
      <EventCard collection={principalToName(event.collection)} unix_time={event.time} operation={event.operation} />
    {/each}
  </div>
{/if}

<style lang="scss">
  @use "../../styles" as *;

  h1,
  h3,
  a {
    --page-feature-color: #{$yellow};
  }

  .title {
    display: grid;
    grid-template-columns: 80px 1fr 1fr 1fr;
    padding: 10px 20px;
    align-items: center;
    font-weight: bold;
  }

  .summary-board {
    display: grid;
    grid-template-columns: 1fr 1fr 1fr;
    padding: 10px 20px;
    gap: 50px;
    align-items: center;
    font-size: large;
    font-weight: bold;
    margin-bottom: 40px;
  }

  .board {
    background-color: #{$verydarkgrey};
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    padding: 20px 40px;
    border-radius: 10px;
  }

  .value {
    text-align: center;
  }

  h4 {
    text-align: center;
  }
</style>
