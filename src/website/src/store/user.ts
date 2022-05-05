import { Principal } from "@dfinity/principal";
import { writable } from "svelte/store";
import { actors } from "./actor";
import type { userStore } from "./types/user-store";

export const user = writable<userStore>({
  loggedIn: false,
  wallet: undefined,
  principal: Principal.anonymous(),
  email: undefined,
  twitter: undefined,
  discord: undefined,
});

// actors.subscribe(async ({ hubActor }) => {
//   console.log("hubActor", hubActor);
//   if (hubActor) {
//     const result = await hubActor.get_user();
//     console.log("result", result);
//     if (result.length > 0) {
//       const email = result[0].email.length > 0 ? result[0].email[0] : null;
//       const twitter = result[0].twitter.length > 0 ? result[0].twitter[0] : null;
//       const discord = result[0].discord.length > 0 ? result[0].discord[0] : null;
//       user.update((u) => ({ ...u, twitter, discord, email }));
//     } else {
//       user.update((u) => ({ ...u, twitter: undefined, discord: undefined, email: undefined }));
//     }
//   }
// });
