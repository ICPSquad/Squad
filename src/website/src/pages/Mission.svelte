<script lang="ts">
  import Header from "@components/shared/Header.svelte";
  import Footer from "@components/shared/Footer.svelte";
  import Join from "@components/shared/Join.svelte";
  import Newsletter from "@components/shared/Newsletter.svelte";
  import MissionCard from "@components/mission/MissionCard.svelte";
  import { hubActor } from "@src/api/actor";
  import type { Mission } from "@canisters/hub/hub.did.d";
  import { getRewardToString } from "@utils/missions";
  import { user } from "@src/store/user";
  import { onDestroy } from "svelte";
  import { actors } from "@src/store/actor";
  import { plugConnection } from "@utils/connection";
  let missions: Mission[] | [] = [];
  let completed: BigInt[] = [];

  async function getMission() {
    missions = await hubActor().get_missions();
  }

  actors.subscribe(async ({ hubActor }) => {
    if (!hubActor) {
      return;
    }
    const result = await hubActor.my_completed_missions();
    console.log("Completed missions", result);
    let new_completed = [];
    result.forEach((info) => {
      new_completed.push(info[0]);
    });
    completed = new_completed;
  });

  async function validateMission(e) {
    let id = e.detail;
    if (!$user.loggedIn) {
      plugConnection();
      return;
    }
    if (confirm("Do you want to validate this mission?")) {
      try {
        let result = await $actors.hubActor.verify_mission(id);
        console.log(result);
        if ("ok" in result) {
          if (result.ok) {
            alert("Your mission has been validated! You will receive the reward shortly.");
          } else {
            alert("This mission cannot be validated. Make sure you have completed the task.");
          }
        } else {
          alert(result.err);
        }
      } catch (e) {
        alert(e.message);
      }
    }
  }

  onDestroy(() => {});

  getMission();
</script>

<Header />
<div class="page-header">
  <h1>Mission</h1>
</div>
{#if !$user.loggedIn}
  <button class="secondary" on:click={() => plugConnection()}> CONNECT WALLET TO VALIDATE MISSIONS </button>
{/if}
<div class="mission-container">
  {#each missions as mission}
    <MissionCard title={mission.title} description={mission.description} reward={getRewardToString(mission)} id={mission.id} {completed} on:validateMission={validateMission} />
  {/each}
</div>
<Join />
<Newsletter />
<Footer />

<style lang="scss">
  @use "../styles" as *;

  h1 {
    --page-feature-color: #{$green};
  }

  .mission-container {
    display: grid;
    grid-template-columns: 1fr 1fr 1fr;
    grid-gap: 20px;
    margin: 60px 60px;
  }

  button {
    margin: 20px auto;
  }
</style>
