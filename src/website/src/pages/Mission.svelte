<script lang="ts">
  import Header from "@components/shared/Header.svelte";
  import Footer from "@components/shared/Footer.svelte";
  import Join from "@components/shared/Join.svelte";
  import Newsletter from "@components/shared/Newsletter.svelte";
  import Categories from "@src/components/mission/Categories.svelte";
  import { hubActor } from "@src/api/actor";
  import type { Mission } from "@canisters/hub/hub.did.d";
  import { user } from "@src/store/user";
  import { onDestroy } from "svelte";
  import { actors } from "@src/store/actor";
  import { plugConnection } from "@utils/connection";
  import MissionSelection from "@src/components/mission/MissionSelection.svelte";
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

  let categoryShowing: string = "general";
  const setCategoryShowing = (category: string) => {
    categoryShowing = category;
  };
</script>

<Header />
<div class="page-header">
  <h1>Mission</h1>
</div>
{#if !$user.loggedIn}
  <button class="secondary" on:click={() => plugConnection()}> CONNECT WALLET TO VALIDATE MISSIONS </button>
{/if}
<main class="container">
  <div class="layout-grid">
    <div class="categories">
      <Categories {categoryShowing} {setCategoryShowing} />
    </div>
    <div class="missions">
      <MissionSelection {categoryShowing} {missions} {completed} on:validateMission={validateMission} />
    </div>
  </div>
</main>
<Join />
<Newsletter />
<Footer />

<style lang="scss">
  @use "../styles" as *;

  h1 {
    --page-feature-color: #{$yellow};
  }

  .layout-grid {
    display: grid;
    grid-template-columns: 1fr 1fr 1fr 1fr;
    grid-gap: 40px;
  }

  @media (max-width: 960px) {
    .layout-grid {
      grid-template-columns: 3fr 3fr 4fr;
      grid-gap: 10px;
      grid-auto-flow: dense;
    }
    .categories {
      grid-column: span 2;
    }
    .item-selection {
      grid-column: span 2;
    }
    .accessory-details {
      grid-row: span 2;
    }
  }
  .missions {
    grid-column: span 3;
    display: grid;
    grid-template-columns: 1fr 1fr;
    grid-gap: 10px;
    grid-auto-flow: dense;
  }

  button {
    margin: 20px auto;
  }
</style>
