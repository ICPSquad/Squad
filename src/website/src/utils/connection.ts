import { avatarID, accessoriesID, invoiceID, ledgerID, hubID } from "./const";
import { idlFactory as idlFactoryAvatar } from "@canisters/avatar/avatar.did";
import { idlFactory as idlFactoryAccessories } from "@canisters/accessories/accessories.did";
import { idlFactory as idlFactoryInvoice } from "@canisters/invoice/invoice.did";
import { idlFactory as idlFactoryLedger } from "@canisters/ledger/ledger.did";
import { idlFactory as idlFactoryHub } from "@canisters/hub/hub.did";
import { StoicIdentity } from "ic-stoic-identity";
import { actors } from "@src/store/actor";
import { get } from "svelte/store";
import { user } from "@src/store/user";
import { Actor, HttpAgent } from "@dfinity/agent";
import type { ICPSquadNFT as Avatar } from "@canisters/avatar/avatar.did.d";
import type { ICPSquadNFT as Accessories } from "@canisters/accessories/accessories.did.d";
import type { Invoice } from "@canisters/invoice/invoice.did.d";
import type { _SERVICE as Ledger } from "@canisters/ledger/ledger.did.d";
import type { _SERVICE as Hub } from "@canisters/hub/hub.did.d";

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
  const hubActor = await window.ic.plug.createActor({
    canisterId: hubID,
    interfaceFactory: idlFactoryHub,
  });

  user.update((u) => ({ ...u, wallet: "plug", loggedIn: true, principal }));
  actors.update((a) => ({ ...a, avatarActor: avatarActor, accessoriesActor: accessoriesActor, invoiceActor: invoiceActor, hubActor: hubActor }));
}

export async function stoicConnexion(): Promise<void> {
  StoicIdentity.load()
    .then((identity) => {
      if (identity == false) {
        StoicIdentity.connect()
          .then((identity) => {
            console.log("Identity", identity);
            user.update((u) => ({ ...u, wallet: "stoic", loggedIn: true, principal: identity.getPrincipal() }));
            const agent = new HttpAgent({
              identity: identity,
              host: process.env.NODE_ENV === "production" ? "https://mainnet.dfinity.network" : "http://127.0.0.1:8000",
            });
            const avatarActor = Actor.createActor<Avatar>(idlFactoryAvatar, {
              agent,
              canisterId: avatarID,
            });
            const accessoriesActor = Actor.createActor<Accessories>(idlFactoryAccessories, {
              agent,
              canisterId: accessoriesID,
            });
            const invoiceActor = Actor.createActor<Invoice>(idlFactoryInvoice, {
              agent,
              canisterId: invoiceID,
            });
            const ledgerActor = Actor.createActor<Ledger>(idlFactoryLedger, {
              agent,
              canisterId: ledgerID,
            });
            const hubActor = Actor.createActor<Hub>(idlFactoryHub, {
              agent,
              canisterId: hubID,
            });
            actors.update((a) => ({ ...a, avatarActor: avatarActor, accessoriesActor: accessoriesActor, invoiceActor: invoiceActor, ledgerActor: ledgerActor, hubActor: hubActor }));
            console.log("Stoic identity connected", identity);
          })
          .catch((error) => {
            alert("Unable to connect to StoicIdentity, please read our FAQ for more informations.");
            console.log("Stoic identity connexion error", error);
          });
      } else {
        user.update((u) => ({ ...u, wallet: "stoic", loggedIn: true, principal: identity.getPrincipal() }));
        const agent = new HttpAgent({
          identity: identity,
          host: process.env.NODE_ENV === "production" ? "https://mainnet.dfinity.network" : "http://127.0.0.1:8000",
        });
        const avatarActor = Actor.createActor<Avatar>(idlFactoryAvatar, {
          agent,
          canisterId: avatarID,
        });
        const accessoriesActor = Actor.createActor<Accessories>(idlFactoryAccessories, {
          agent,
          canisterId: accessoriesID,
        });
        const invoiceActor = Actor.createActor<Invoice>(idlFactoryInvoice, {
          agent,
          canisterId: invoiceID,
        });
        const ledgerActor = Actor.createActor<Ledger>(idlFactoryLedger, {
          agent,
          canisterId: ledgerID,
        });
        const hubActor = Actor.createActor<Hub>(idlFactoryHub, {
          agent,
          canisterId: hubID,
        });
        actors.update((a) => ({ ...a, avatarActor: avatarActor, accessoriesActor: accessoriesActor, invoiceActor: invoiceActor, ledgerActor: ledgerActor, hubActor: hubActor }));
      }
    })
    .catch((error) => {
      alert("Unable to load your StoicIdentity, please read our FAQ for more informations.");
      console.log("StoicIdentity loading error", error);
    });
}

export function disconnectWallet(): void {
  const { wallet: Wallet } = get(user);
  if (Wallet === "plug") {
    window.ic.plug.disconnect();
  }
  if (Wallet === "stoic") {
    StoicIdentity.disconnect();
  }
  user.update((u) => ({ ...u, wallet: undefined, loggedIn: false, principal: null }));
  actors.update((a) => ({ ...a, avatarActor: null, accessoriesActor: null, invoiceActor: null, ledgerActor: null, hubActor: null }));
}

export async function persistConnexion(): Promise<void> {
  const promises = [window.ic.plug.isConnected(), StoicIdentity.load()];
  const [plugConnected, stoicConnected] = await Promise.all(promises);
  if (plugConnected) {
    // Initialize and stores the actor
    const principal = await window.ic.plug.getPrincipal();
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
    const hubActor = await window.ic.plug.createActor({
      canisterId: hubID,
      interfaceFactory: idlFactoryHub,
    });

    user.update((u) => ({ ...u, wallet: "plug", loggedIn: true, principal }));
    actors.update((a) => ({ ...a, avatarActor: avatarActor, accessoriesActor: accessoriesActor, invoiceActor: invoiceActor, hubActor: hubActor }));
  } else if (stoicConnected) {
    try {
      const principal = stoicConnected.getPrincipal();
      let agent = new HttpAgent({
        identity: stoicConnected,
        host: process.env.NODE_ENV === "production" ? "https://mainnet.dfinity.network" : "http://127.0.0.1:8000",
      });
      const avatarActor = Actor.createActor<Avatar>(idlFactoryAvatar, {
        agent,
        canisterId: avatarID,
      });
      const accessoriesActor = Actor.createActor<Accessories>(idlFactoryAccessories, {
        agent,
        canisterId: accessoriesID,
      });
      const invoiceActor = Actor.createActor<Invoice>(idlFactoryInvoice, {
        agent,
        canisterId: invoiceID,
      });
      const ledgerActor = Actor.createActor<Ledger>(idlFactoryLedger, {
        agent,
        canisterId: ledgerID,
      });
      const hubActor = Actor.createActor<Hub>(idlFactoryHub, {
        agent,
        canisterId: hubID,
      });
      user.update((u) => ({ ...u, wallet: "stoic", loggedIn: true, principal }));
      actors.update((a) => ({ ...a, avatarActor: avatarActor, accessoriesActor: accessoriesActor, invoiceActor: invoiceActor, ledgerActor: ledgerActor, hubActor: hubActor }));
    } catch (e) {
      alert("Error logging in with stoic, please ensure cookies are enabled and Brave protection is disabled");
      throw e;
    }
  } else {
    return;
  }
}
