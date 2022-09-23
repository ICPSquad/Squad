<script lang="ts">
  import { NFTRegistry } from "@psychedelic/dab-js";
  import EventCard from "./EventCard.svelte";
  import type { Principal } from "@dfinity/principal";
  import { _isAccessoryBurnEvent, _isAccessoryMintEvent } from "@utils/event";
  import type { ExtendedEvent } from "@canisters/hub/hub.did.d";
  import type { FormattedMetadata } from "@psychedelic/dab-js/dist/utils/registry";

  export let extended_events: Array<ExtendedEvent>;
  let registry: NFTRegistry = new NFTRegistry();
  let informations: FormattedMetadata[] | null = null;

  $: nb_interacted_collection = _getNumberInteractedCollections(extended_events);
  $: nb_burned_accessories = _getNumberBurnedAccessories(extended_events);
  $: nb_minted_accessories = _getNumberMintedAccessories(extended_events);

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

  function _getNumberInteractedCollections(list: ExtendedEvent[]): number {
    let collections: string[] = [];
    list.forEach((i) => {
      if (!collections.includes(i.collection.toText())) {
        collections.push(i.collection.toText());
      }
    });
    console.log("collections", collections);
    return collections.length;
  }

  function _getNumberBurnedAccessories(list: ExtendedEvent[]): number {
    let burned = 0;
    list.forEach((i) => {
      if (_isAccessoryBurnEvent(i)) {
        burned += 1;
      }
    });
    return burned;
  }

  function _getNumberMintedAccessories(list: ExtendedEvent[]): number {
    let minted = 0;
    list.forEach((i) => {
      if (_isAccessoryMintEvent(i)) {
        minted += 1;
      }
    });
    return minted;
  }

  updateInformations();
</script>

{#if extended_events && extended_events.length > 0 && informations}
  <div class="container">
    <div class="summary-board">
      <div class="board">
        <h4>Interacted collections</h4>
        <div class="value">{nb_interacted_collection}</div>
      </div>
      <div class="board">
        <h4>Burned accessories</h4>
        <div class="value">{nb_burned_accessories}</div>
      </div>
      <div class="board">
        <h4>Minted accessories</h4>
        <div class="value">{nb_minted_accessories}</div>
      </div>
    </div>

    <div class="title">
      <div />
      <div class="event">Event</div>
      <div class="collection">Collection</div>
      <div class="date hide-on-mobile">Date</div>
    </div>
    {#each extended_events as event}
      <EventCard collection={principalToName(event.collection)} {event} />
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

  @media (max-width: 768px) {
    .summary-board {
      display: flex;
      flex-direction: column;
      gap: 20px;
    }
    .title {
      grid-template-columns: 80px 1fr 1fr;
      font-size: small;
    }

    .hide-on-mobile {
      display: none;
    }
  }
</style>
