import type { AvatarRendering } from "@canisters/avatar/avatar.did.d";

export type AvatarStore = {
  tokenIdentifier: string | null | undefined;
  rendering: AvatarRendering | null | undefined;
};
