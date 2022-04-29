import "isomorphic-fetch";
import { Actor, ActorSubclass, HttpAgent, HttpAgentOptions, Identity } from "@dfinity/agent";
import { IDL } from "@dfinity/candid";
import { Principal } from "@dfinity/principal";
import { readFileSync } from "fs";
import { } from "@declarations/"
import { ICPSquadNFT as Avatar } from "@declarations/avatar/avatar.did";
import { idlFactory as idlFactoryAccessories } from "./canisters/declarations/accessories/accessories.did";
import { ICPSquadNFT as Accessories } from "./canisters/declarations/accessories/accessories.did";
import { idlFactory as idlFactoryHub } from "./canisters/declarations/hub/hub.did";
import { ICPSquadHub as Hub } from "./canisters/declarations/hub/hub.did";
import { idlFactory as idlFactoryInvoice } from "./canisters/declarations/invoice/invoice.did";
import { Invoice } from "./canisters/declarations/invoice/invoice.did";
import { identity } from "svelte/internal";

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

export funtion ledgerActor(identity? : Identity): ActorSubclass<Ledger> {