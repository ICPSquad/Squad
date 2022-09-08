import type { Principal } from "@dfinity/principal";
import type { Activity, ExtendedEvent, Mission } from "@canisters/hub/hub.did.d";
import type { Reward } from "@canisters/accessories/accessories.did.d";
import { get } from "svelte/store";
import { actors } from "@src/store/actor";

export async function getCompletedMissions(p: Principal): Promise<[Mission, bigint][]> {
  let hubActor = get(actors).hubActor;
  if (!hubActor) {
    throw new Error("Hub actor not found");
  }
  let completed = await hubActor.get_completed_missions(p);
  return completed;
}

export async function getRecordedRewards(p: Principal): Promise<[Array<Reward>] | []> {
  let accessoriesActor = get(actors).accessoriesActor;
  if (!accessoriesActor) {
    throw new Error("Accessories actor not found");
  }
  let airdropped = await accessoriesActor.get_recorded_rewards(p);
  return airdropped;
}

export async function getRecordedEvents(p: Principal): Promise<[] | [ExtendedEvent[]]> {
  let hubActor = get(actors).hubActor;
  if (!hubActor) {
    throw new Error("Hub actor not found");
  }
  let events = await hubActor.get_recorded_events(p, [], []);
  return events;
}
