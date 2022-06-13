import { avatarID, accessoriesID, invoiceID, ledgerID, hubID } from "./const";
import { idlFactory as idlFactoryAvatar } from "@canisters/avatar/avatar.did";
import { idlFactory as idlFactoryAccessories } from "@canisters/accessories/accessories.did";
import { idlFactory as idlFactoryInvoice } from "@canisters/invoice/invoice.did";
import { idlFactory as idlFactoryLedger } from "@canisters/ledger/ledger.did";
import { idlFactory as idlFactoryHub } from "@canisters/hub/hub.did";
import { StoicIdentity } from "ic-stoic-identity";

import { actors } from "@src/store/actor";
import { user } from "@src/store/user";
import { Actor, HttpAgent } from "@dfinity/agent";

export async function plugConnection(): Promise<void> {
  const result = await window.ic.plug.requestConnect({
    whitelist: [avatarID, accessoriesID, invoiceID, ledgerID, hubID],
  });
  if (!result) {
    throw new Error("Unable to connect to Plug wallet");
  }
  // Initialize and stores the actor
  const principal = await window.ic.plug.agent.getPrincipal();
  const avatarActor = await window.ic.plug.createActor({
    canisterId: avatarID,
    interfaceFactory: idlFactoryAvatar,
  });
  const accessoriesActor = await window.ic.plug.createActor({
    canisterId: accessoriesID,
    interfaceFactory: idlFactoryAccessories,
  });
  const invoiceActor = await window.ic.plug.createActor({
    canisterId: invoiceID,
    interfaceFactory: idlFactoryInvoice,
  });
  const ledgerActor = await window.ic.plug.createActor({
    canisterId: ledgerID,
    interfaceFactory: idlFactoryLedger,
  });
  const hubActor = await window.ic.plug.createActor({
    canisterId: hubID,
    interfaceFactory: idlFactoryHub,
  });
  user.update((u) => ({ ...u, wallet: "plug", loggedIn: true, principal }));
  actors.update((a) => ({ ...a, avatarActor: avatarActor, accessoriesActor: accessoriesActor, invoiceActor: invoiceActor, ledgerActor: ledgerActor, hubActor: hubActor }));
}

export async function stoicConnexion(): Promise<void> {
  try {
    StoicIdentity.load().then(async (identity) => {
      if (identity !== false) {
        //ID is a already connected wallet!
      } else {
        identity = await StoicIdentity.connect();
      }
      try {
        await identity.sign("a");
        const principal = identity.getPrincipal();
        const avatarActor = Actor.createActor(idlFactoryAvatar, {
          agent: new HttpAgent({ identity }),
          canisterId: avatarID,
        });
        const accessoriesActor = Actor.createActor(idlFactoryAccessories, {
          agent: new HttpAgent({ identity }),
          canisterId: accessoriesID,
        });
        const invoiceActor = Actor.createActor(idlFactoryInvoice, {
          agent: new HttpAgent({ identity }),
          canisterId: invoiceID,
        });
        const ledgerActor = Actor.createActor(idlFactoryLedger, {
          agent: new HttpAgent({ identity }),
          canisterId: ledgerID,
        });
        const hubActor = Actor.createActor(idlFactoryHub, {
          agent: new HttpAgent({ identity }),
          canisterId: hubID,
        });
        user.update((u) => ({ ...u, wallet: "stoic", loggedIn: true, principal }));
        //@ts-ignore
        actors.update((a) => ({ ...a, avatarActor: avatarActor, accessoriesActor: accessoriesActor, invoiceActor: invoiceActor, ledgerActor: ledgerActor, hubActor: hubActor }));
      } catch (e) {
        alert("Error logging in with stoic, please ensure cookies are enabled.");
        return;
      }
    });
  } catch (e) {
    alert(e);
    return;
  }
}
