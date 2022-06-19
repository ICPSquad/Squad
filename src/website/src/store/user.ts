import { Principal } from "@dfinity/principal";
import { writable, get } from "svelte/store";
import { actors } from "./actor";
import type { userStore } from "./types/user-store";

export const user = writable<userStore>({
  loggedIn: false,
  wallet: undefined,
  principal: Principal.anonymous(),
  username: undefined,
  email: undefined,
  twitter: undefined,
  discord: undefined,
  avatarDefault: undefined,
  avatars: [],
});

actors.subscribe(async ({ avatarActor }) => {
  if (avatarActor) {
    let promises = [avatarActor.get_user(), avatarActor.get_avatars()];
    Promise.all(promises)
      .then(([infos, avatars]) => {
        console.log("avatars", avatars);
        console.log("infos", infos);
        if (infos.length > 0) {
          // @ts-ignore
          const username = infos[0].name.length > 0 ? infos[0].name[0] : null;
          // @ts-ignore
          const email = infos[0].email.length > 0 ? infos[0].email[0] : null;
          // @ts-ignore
          const twitter = infos[0].twitter.length > 0 ? infos[0].twitter[0] : null;
          // @ts-ignore
          const discord = infos[0].discord.length > 0 ? infos[0].discord[0] : null;
          // @ts-ignore
          const avatarDefault = infos[0].selected_avatar.length > 0 ? infos[0].selected_avatar : null;
          user.update((u) => ({ ...u, loggedIn: true, username, email, twitter, discord, avatarDefault }));
        }
        if (avatars.length > 0) {
          //@ts-ignore
          user.update((u) => ({ ...u, avatars }));
        }
      })
      .catch((err) => {
        console.error(err);
      });
  }
});

export function isLoggedIn(): boolean {
  return get(user).loggedIn;
}
