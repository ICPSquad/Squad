import { Actor, HttpAgent } from "@dfinity/agent";
import type { ActorSubclass, HttpAgentOptions, Identity } from "@dfinity/agent";
import type { IDL } from "@dfinity/candid";
import type { Principal } from "@dfinity/principal";
import { idlFactory as idlFactoryAvatar } from "@canisters/avatar/avatar.did";
import type { ICPSquadNFT as Avatar } from "@canisters/avatar/avatar.did.d";
import { idlFactory as idlFactoryAccessories } from "@canisters/accessories/accessories.did";
import type { ICPSquadNFT as Accessories } from "@canisters/accessories/accessories.did.d";
import { idlFactory as idlFactoryHub } from "@canisters/hub/hub.did";
import type { ICPSquadHub as Hub } from "@canisters/hub/hub.did.d";
import { idlFactory as idlFactoryInvoice } from "@canisters/invoice/invoice.did";
import type { Invoice } from "@canisters/invoice/invoice.did.d";
import { idlFactory as idlFactoryLedger } from "@canisters/ledger/ledger.did";
import type { _SERVICE as Ledger } from "@canisters/ledger/ledger.did.d";
import { avatarID, accessoriesID, hubID, invoiceID, ledgerID, HOST } from "@utils/const";

function createActor<T>(canisterId: string | Principal, idlFactory: IDL.InterfaceFactory, options: HttpAgentOptions): ActorSubclass<T> {
  const agent = new HttpAgent({
    host: HOST,
    ...options,
  });
  if (process.env.NODE_ENV == "development") {
    agent.fetchRootKey().catch((err) => {
      console.warn("Unable to fetch root key. Check to ensure that your local replica is running");
      console.error(err);
    });
  }
  return Actor.createActor(idlFactory, {
    agent,
    canisterId,
  });
}

export function avatarActor(identity?: Identity): ActorSubclass<Avatar> {
  return createActor(avatarID, idlFactoryAvatar, {
    identity,
  });
}

export function accessoriesActor(identity?: Identity): ActorSubclass<Accessories> {
  return createActor(accessoriesID, idlFactoryAccessories, {
    identity,
  });
}

export function hubActor(identity?: Identity): ActorSubclass<Hub> {
  return createActor(hubID, idlFactoryHub, {
    identity,
  });
}

export function invoiceActor(identity?: Identity): ActorSubclass<Invoice> {
  return createActor(invoiceID, idlFactoryInvoice, {
    identity,
  });
}

export function ledgerActor(identity?: Identity): ActorSubclass<Ledger> {
  return createActor(ledgerID, idlFactoryLedger, {
    identity,
  });
}
