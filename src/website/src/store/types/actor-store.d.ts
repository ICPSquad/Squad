import type { ActorSubclass } from "@dfinity/agent";
import type { ICPSquadNFT as Avatar } from "@canisters/avatar/avatar.did.d";
import type { ICPSquadNFT as Accessories } from "@canisters/accessories/accessories.did.d";
import type { ICPSquadHub as Hub } from "@canisters/hub/hub.did.d";
import type { Invoice } from "@canisters/invoice/invoice.did.d";
import type { _SERVICE as Ledger } from "@canisters/ledger/ledger.did.d";

export type actorStore = {
  avatarActor: ActorSubclass<Avatar> | undefined;
  accessoriesActor: ActorSubclass<Accessories> | undefined;
  hubActor: ActorSubclass<Hub> | undefined;
  invoiceActor: ActorSubclass<Invoice> | undefined; //Do we really need this one ?
  ledgerActor: ActorSubclass<Ledger> | undefined;
};
