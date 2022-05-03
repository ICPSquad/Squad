import "isomorphic-fetch";
import { readFileSync } from "fs";
import type { ActorSubclass, HttpAgentOptions, Identity } from "@dfinity/agent";
import { HttpAgent, Actor } from "@dfinity/agent";
import type { IDL } from "@dfinity/candid";
import type { Principal } from "@dfinity/principal";
import { idlFactory as idlFactoryAvatar } from "@declarations/avatar/avatar.did";
import type { ICPSquadNFT as Avatar } from "@declarations/avatar/avatar.did.d";
import { idlFactory as idlFactoryAccessories } from "./canisters/declarations/accessories/accessories.did";
import type { ICPSquadNFT as Accessories } from "./canisters/declarations/accessories/accessories.did.d";
import { idlFactory as idlFactoryHub } from "./canisters/declarations/hub/hub.did";
import type { ICPSquadHub as Hub } from "./canisters/declarations/hub/hub.did.d";
import { idlFactory as idlFactoryInvoice } from "./canisters/declarations/invoice/invoice.did";
import type { Invoice } from "@declarations/invoice/invoice.did.d";

function createActor<T>(canisterId: string | Principal, idlFactory: IDL.InterfaceFactory, options: HttpAgentOptions): ActorSubclass<T> {
  const agent = new HttpAgent({
    host: process.env.NODE_ENV === "production" ? "https://mainnet.dfinity.network" : "http://127.0.0.1:8000",
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

const canisters =
  process.env.NODE_ENV === "production"
    ? JSON.parse(readFileSync(`${__dirname}/../canister_ids.json`).toString())
    : JSON.parse(readFileSync(`${__dirname}/../.dfx/local/canister_ids.json`).toString());
const avatarID = process.env.NODE_ENV === "production" ? canisters.avatar.ic : canisters.avatar.local;
const accessoriesID = process.env.NODE_ENV === "production" ? canisters.accessories.ic : canisters.accessories.local;
const hubID = process.env.NODE_ENV === "production" ? canisters.hub.ic : canisters.hub.local;
const invoiceID = process.env.NODE_ENV === "production" ? canisters.invoice.ic : canisters.invoice.local;

function avatarActor(identity?: Identity): ActorSubclass<Avatar> {
  return createActor(avatarID, idlFactoryAvatar, {
    identity,
  });
}
function accessoriesActor(identity?: Identity): ActorSubclass<Accessories> {
  return createActor(accessoriesID, idlFactoryAccessories, {
    identity,
  });
}

function hubActor(identity?: Identity): ActorSubclass<Hub> {
  return createActor(hubID, idlFactoryHub, {
    identity,
  });
}

function invoiceActor(identity?: Identity): ActorSubclass<Invoice> {
  return createActor(invoiceID, idlFactoryInvoice, {
    identity,
  });
}

export { avatarActor, accessoriesActor, hubActor, invoiceActor };
