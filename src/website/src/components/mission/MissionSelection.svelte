<script lang="ts">
  import MissionCard from "@components/mission/MissionCard.svelte";
  import { createEventDispatcher } from "svelte";
  import type { Mission } from "@canisters/hub/hub.did.d";
  import { categoryToMission } from "@utils/mission";
  export let categoryShowing: string;
  export let missions: Mission[];
  export let completed: BigInt[];

  let dispatch = createEventDispatcher();
  const validateMission = (e) => {
    let id = e.detail;
    dispatch("validateMission", id);
  };

  $: missionsSelection = categoryToMission(categoryShowing, missions);
</script>

{#each missionsSelection as mission}
  <MissionCard {mission} {completed} on:validateMission={validateMission} />
{/each}
