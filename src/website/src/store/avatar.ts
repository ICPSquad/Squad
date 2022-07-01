import type { AvatarStore } from "./types/avatar-store";
import { writable, get } from "svelte/store";
import { actors } from "./actor";
import { user } from "./user";

export const avatar = writable<AvatarStore>({
  tokenIdentifier: null,
  rendering: null,
});

actors.subscribe(async ({ avatarActor }) => {
  const { principal: principal } = get(user);
  if (avatarActor && principal) {
    const result = await avatarActor.get_avatar_infos();
    console.log("Get avatar infos", result);
    if (result[0].length > 0 && result[1].length > 0) {
      //@ts-ignore
      avatar.update((a) => ({ ...a, rendering: result[1][0], tokenIdentifier: result[0][0] }));
    } else {
      throw new Error("No avatar found");
    }
  }
});

export async function updateAvatar(): Promise<void> {
  const { avatarActor } = get(actors);
  if (!avatarActor) {
    return;
  }
  const result = await avatarActor.get_avatar_infos();
  if (result[0].length > 0 && result[1].length > 0) {
    //@ts-ignore
    avatar.update((a) => ({ ...a, rendering: result[1][0], tokenIdentifier: result[0][0] }));
  } else {
    throw new Error("No avatar found");
  }
}
