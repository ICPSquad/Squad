import { Wallet } from "@src/types/wallet";
import type { Principal } from "@dfinity/principal";
import type { Identity } from "@dfinity/agent";

export type userStore = {
  loggedIn: boolean;
  principal: Principal;
  wallet: Wallet | undefined;
  username: string | undefined | null;
  email: string | undefined | null;
  twitter: string | undefined | null;
  discord: string | undefined | null;
  avatarDefault: string | undefined | null;
  avatars: string[] | undefined | null;
};
