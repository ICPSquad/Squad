import { HOST, avatarID, accessoriesID, invoiceID, ledgerID } from "./const";
import { idlFactory as idlFactoryAvatar } from "@canisters/avatar/avatar.did";
import { idlFactory as idlFactoryAccessories } from "@canisters/accessories/accessories.did";
import { idlFactory as idlFactoryInvoice } from "@canisters/invoice/invoice.did";
import { idlFactory as idlFactoryLedger } from "@canisters/ledger/ledger.did";

import { actors } from "@src/store/actor";
import { user } from "@src/store/user";

export const plugConnection = async () => {
  const result = await window.ic.plug.requestConnect({
    whitelist: [avatarID, accessoriesID, invoiceID, ledgerID],
    host: HOST,
  });
  if (!result) {
    throw new Error("Unable to connect to the plug");
  }

  const principal = await window.ic.plug.agent.getPrincipal();
  console.log("principal", principal);
  user.update((u) => ({ ...u, wallet: "plug", loggedIn: true, principal }));

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
  actors.update((a) => ({ ...a, avatarActor: avatarActor, accessoriesActor: accessoriesActor, invoiceActor: invoiceActor, ledgerActor: ledgerActor }));
};
