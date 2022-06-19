import { principalToAddressBytes, principalToAddress } from "./principal";
import { toHexString } from "./bits";
import type { AccountIdentifier } from "@canisters/invoice/invoice.did.d";

export function accountIdentifierToBytes(accountIdentifier: AccountIdentifier): Array<number> {
  if ("blob" in accountIdentifier) {
    return accountIdentifier.blob;
  } else if ("principal" in accountIdentifier) {
    return principalToAddressBytes(accountIdentifier.principal);
  } else if ("text" in accountIdentifier) {
    return Array.from(new Uint8Array(Buffer.from(accountIdentifier.text, "hex")));
  } else {
    throw new Error("Unknown accountIdentifier type");
  }
}

export function accountIdentifierToString(accountIdentifier: AccountIdentifier): string {
  if ("text" in accountIdentifier) {
    return accountIdentifier.text;
  } else if ("blob" in accountIdentifier) {
    return toHexString(accountIdentifier.blob);
  } else if ("principal" in accountIdentifier) {
    return principalToAddress(accountIdentifier.principal);
  }
}
