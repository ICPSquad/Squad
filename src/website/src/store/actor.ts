import type { actorStore } from "./types/actor-store.d";
import { writable } from "svelte/store";

export const actors = writable<actorStore>({
  avatarActor: undefined,
  accessoriesActor: undefined,
  invoiceActor: undefined,
  ledgerActor: undefined,
  hubActor: undefined,
});
