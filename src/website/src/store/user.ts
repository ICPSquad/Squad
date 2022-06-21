import type { User, UserData } from "@canisters/avatar/avatar.did.d";
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
          let data = infos[0] as UserData;

          const username = data.name.length > 0 ? data.name[0] : null;
          const email = data.email.length > 0 ? data.email[0] : null;
          const twitter = data.twitter.length > 0 ? data.twitter[0] : null;
          const discord = data.discord.length > 0 ? data.discord[0] : null;
          const selected_avatar = data.selected_avatar.length > 0 ? data.selected_avatar[0] : null;

          user.update((u) => ({ ...u, loggedIn: true, username, email, twitter, discord, avatarDefault: selected_avatar }));
        }
        if (avatars.length > 0) {
          user.update((u) => ({ ...u, avatars: avatars as string[] }));
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
