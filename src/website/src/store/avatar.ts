import type { AvatarStore } from "./types/avatar-store";
import { writable, get } from "svelte/store";
import { actors } from "./actor";
import { user } from "./user";
import { principalToAddress } from "@src/utils/tools/principal";

export const avatar = writable<AvatarStore>({
  tokenIdentifier: null,
});

actors.subscribe(async ({ avatarActor }) => {
  const { principal: principal } = get(user);
  if (avatarActor && principal) {
    const aid = principalToAddress(principal);
    const result = await avatarActor.tokens_id(aid);
    if ("ok" in result) {
      let tokens_id = result.ok;
      if (tokens_id.length > 0) {
        avatar.update((a) => ({ ...a, tokenIdentifier: tokens_id[0] }));
      } else {
        avatar.update((a) => ({ ...a, tokenIdentifier: null }));
      }
    } else {
      throw new Error("Could not get avatar");
    }
  }
});
