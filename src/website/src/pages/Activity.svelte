<script lang="ts">
  import { onDestroy } from "svelte";
  import Header from "@components/shared/Header.svelte";
  import Footer from "@components/shared/Footer.svelte";
  import Join from "@components/shared/Join.svelte";
  import ConnectDialog from "@src/components/shared/ConnectDialog.svelte";
  import Newsletter from "@components/shared/Newsletter.svelte";
  import { user } from "@src/store/user";
  import { actors } from "@src/store/actor";
  import { dialog } from "../store/dialog";
  import type { ExtendedEvent } from "@canisters/hub/hub.did.d";
  import ActivityList from "../components/activity/ActivityList.svelte";

  export let extended_events_non_sorted: ExtendedEvent[] | [] = [];

  $: extended_events =
    extended_events_non_sorted.length > 0
      ? extended_events_non_sorted.sort((a, b) => {
          // @ts-ignore
          return Number(b.time) - Number(a.time);
        })
      : [];

  actors.subscribe(async ({ hubActor }) => {
    if (!hubActor) {
      return;
    }
    const result = await hubActor.get_recorded_events($user.principal, [], []);
    if (result.length > 0) {
      extended_events_non_sorted = result[0];
    } else {
      extended_events_non_sorted = [];
    }
  });

  onDestroy(() => {});
</script>

<Header />
<div class="page-header">
  <h1>Activity</h1>
</div>
{#if !$user.loggedIn && extended_events != null}
  <button class="secondary" on:click={() => $dialog.open()}> CONNECT WALLET TO ACCESS YOUR ACTIVITY </button>
  <ConnectDialog />
{:else}
  <ActivityList {extended_events} />
{/if}
<Join />
<Newsletter />
<Footer />

<style lang="scss">
  @use "../styles" as *;

  h1,
  h3,
  a {
    --page-feature-color: #{$yellow};
  }

  button {
    margin: 20px auto;
  }

  .title {
    display: grid;
    grid-template-columns: 80px 1fr 1fr 1fr 120px;
    padding: 10px 20px;
    align-items: center;
    font-size: large;
    font-weight: bold;
  }
</style>
