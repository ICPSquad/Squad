import { Wallet } from "@src/types/wallet";
import type { Principal } from "@dfinity/principal";
import type { Identity } from "@dfinity/agent";

export type userStore = {
  loggedIn: boolean;
  principal: Principal;
  wallet: Wallet | undefined;
  email: string | undefined | null;
  twitter: string | undefined | null;
  discord: string | undefined | null;
};
