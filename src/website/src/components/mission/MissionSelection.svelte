<script lang="ts">
  import MissionCard from "@components/mission/MissionCard.svelte";
  import { createEventDispatcher } from "svelte";
  import type { Mission } from "@canisters/hub/hub.did.d";
  import { getRewardToString } from "@utils/missions";
  export let categoryShowing: string;
  export let missions: Mission[];
  export let completed: BigInt[];

  function categoryToMission(category: string): Mission[] {
    return missions;
  }

  let dispatch = createEventDispatcher();
  const validateMission = (e) => {
    let id = e.detail.id;
    dispatch("validateMission", id);
  };

  $: missions = categoryToMission(categoryShowing);
</script>

{#each missions as mission}
  <MissionCard title={mission.title} description={mission.description} reward={getRewardToString(mission)} id={mission.id} {completed} on:validateMission={validateMission} />
{/each}
