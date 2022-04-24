import { Principal } from "@dfinity/principal";
import { sha224 } from "js-sha256";
import crc32 from "./utils/crc32";

export function getAccountIdentifier(principal: Principal, subAccount?: Uint8Array): Array<number> {
  const array = new Uint8Array([...Buffer.from("\x0Aaccount-id"), ...principal.toUint8Array(), ...getSubAccountArray(subAccount)]);
  const hash = new Uint8Array(sha224.create().update(array).array());
  return Array.from(new Uint8Array([...crc32(hash), ...hash]));
}

const ZERO_SUBACCOUNT = new Uint8Array(32).fill(0);

function getSubAccountArray(subAccount?: Uint8Array): Uint8Array {
  if (!subAccount) return ZERO_SUBACCOUNT;
  return new Uint8Array([...new Uint8Array(32 - subAccount.length), ...subAccount]);
}
