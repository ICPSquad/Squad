import type { Principal } from "@dfinity/principal";
import type { Activity, Mission } from "@canisters/hub/hub.did.d";
import { get } from "svelte/store";
import { actors } from "@src/store/actor";

export async function getCumulativeActivity(p: Principal): Promise<Activity> {
  let hubActor = get(actors).hubActor;
  if (!hubActor) {
    throw new Error("Hub actor not found");
  }
  let activity = await hubActor.get_cumulative_activity(p, [], []);
  return activity;
}

export async function getCompletedMissions(p: Principal): Promise<[Mission, bigint][]> {
  let hubActor = get(actors).hubActor;
  if (!hubActor) {
    throw new Error("Hub actor not found");
  }
  let completed = await hubActor.get_completed_missions(p);
  return completed;
}
