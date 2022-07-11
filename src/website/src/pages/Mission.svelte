<script lang="ts">
  import Header from "@components/shared/Header.svelte";
  import Footer from "@components/shared/Footer.svelte";
  import Join from "@components/shared/Join.svelte";
  import Newsletter from "@components/shared/Newsletter.svelte";
  import Categories from "@src/components/mission/Categories.svelte";
  import Toast from "@src/components/shared/Toast.svelte";
  import { dialog } from "../store/dialog";
  import { hubActor } from "@src/api/actor";
  import type { Mission } from "@canisters/hub/hub.did.d";
  import { user } from "@src/store/user";
  import { setMessage } from "@src/store/toast";
  import { onDestroy } from "svelte";
  import { actors } from "@src/store/actor";
  import MissionSelection from "@src/components/mission/MissionSelection.svelte";
  import ConnectDialog from "@src/components/shared/ConnectDialog.svelte";
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
    let new_completed = [];
    result.forEach((info) => {
      new_completed.push(info[0]);
    });
    completed = new_completed;
  });

  const validateMission = async (e) => {
    let id = e.detail;
    if (!$user.loggedIn) {
      setMessage("You must be logged in to validate a mission", "error", 3000);
      return;
    }
    if (confirm("Do you want to validate this mission?")) {
      setMessage("Validating mission...", "waiting");
      try {
        let result = await $actors.hubActor.verify_mission(id);
        if ("ok" in result) {
          if (result.ok) {
            completed.push(id);
            setMessage("The mission has been validated. Your reward will be sent shortly.", "success", 3000);
          } else {
            setMessage("This mission cannot be validated. Make sure you have completed the task.", "error", 5000);
          }
        } else {
          alert("Critical error : " + result.err + "\nPlease report this issue.");
          setMessage(result.err, "error", 5000);
        }
      } catch (e) {
        alert(e.message);
      }
    }
  };

  onDestroy(() => {});

  getMission();

  // Category selection
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
  <button class="secondary" on:click={() => $dialog.open()}> CONNECT WALLET TO VALIDATE MISSIONS </button>
  <ConnectDialog />
{/if}
<main class="container">
  <div class="layout-grid">
    <div class="categories">
      <Categories {categoryShowing} {setCategoryShowing} />
      <a href="https://dsquad.gitbook.io/docs/engage/missions" target="_blank"> <button class="secondary"> Read documentation </button> </a>
    </div>
    <div class="missions">
      <MissionSelection {categoryShowing} {missions} {completed} on:validateMission={validateMission} />
    </div>
  </div>
</main>
<Join />
<Newsletter />
<Footer />
<Toast />

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
    grid-gap: 20px;
    grid-auto-flow: dense;
  }

  button {
    margin: 20px auto;
  }
</style>
