import type { actorStore } from "./types/actor-store.d";
import { writable } from "svelte/store";

export const actors = writable<actorStore>({
  avatarActor: undefined,
  accessoriesActor: undefined,
  hubActor: undefined,
  invoiceActor: undefined,
  ledgerActor: undefined,
});
