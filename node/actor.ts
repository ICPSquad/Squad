import "isomorphic-fetch";
import { Actor, ActorSubclass, HttpAgent, HttpAgentOptions, Identity } from "@dfinity/agent";
import { IDL } from "@dfinity/candid";
import { Principal } from "@dfinity/principal";
import { readFileSync } from "fs";
import { idlFactory as idlFactoryAvatar } from "./declarations/avatar/avatar.did";
import { ICPSquadNFT as Avatar } from "./declarations/avatar/avatar.did.d";
import { idlFactory as idlFactoryAccessories } from "./declarations/accessories/accessories.did";
import { ICPSquadNFT as Accessories } from "./declarations/accessories/accessories.did.d";
import { idlFactory as idlFactoryHub } from "./declarations/hub/hub.did";
import { ICPSquadHub as Hub } from "./declarations/hub/hub.did.d";
import { idlFactory as idlFactoryInvoice } from "./declarations/invoice/invoice.did";
import { Invoice } from "./declarations/invoice/invoice.did.d";

require("dotenv").config();

function createActor<T>(canisterId: string | Principal, idlFactory: IDL.InterfaceFactory, options: HttpAgentOptions): ActorSubclass<T> {
  const agent = new HttpAgent({
    host: process.env.HOST,
    ...options,
  });
  if (process.env.NETWORK != "IC") {
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

const canisters = JSON.parse(readFileSync(`${__dirname}/../.dfx/local/canister_ids.json`).toString());
const avatarID = canisters.avatar.local;
const accessoriesID = canisters.accessories.local;
const invoiceID = canisters.invoice.local;
const hubID = canisters.hub.local;

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
