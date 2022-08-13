import { actors } from "../store/actor";
import { get } from "svelte/store";
import type { Invoice__1 as Invoice, Category } from "@canisters/invoice/invoice.did.d";

export async function createInvoice(type: string): Promise<Invoice> {
  const { invoiceActor: invoiceActor } = get(actors);
  if (!invoiceActor) {
    throw new Error("No invoice actor");
  }
  const category: Category = stringTypeToVariant(type);
  const create_invoice_result = await invoiceActor.create_invoice(category);
  if ("ok" in create_invoice_result) {
    return create_invoice_result.ok.invoice;
  } else {
    throw new Error("Error during invoice creation");
  }
}

function stringTypeToVariant(type: string): Category {
  switch (type) {
    case "AvatarMint":
      return { AvatarMint: null };
    case "AccessoryFee":
      return { AccessoryFee: null };
    case "Ticket":
      return { Ticket: null };
    default:
      throw new Error("Unknown type");
  }
}
