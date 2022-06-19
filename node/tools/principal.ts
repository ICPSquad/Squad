import type { Principal } from "@dfinity/principal";
import { sha224 } from "js-sha256";
import { crc32Number } from "./crc32";
import { to32bits, toHexString } from "./bits";

export function principalToAddressBytes(principal: Principal, subaccount: number | number[] | undefined = 0): number[] {
  const padding = Buffer.from("\x0Aaccount-id");
  const array = new Uint8Array([...padding, ...principal.toUint8Array(), ...getSubAccountArray(subaccount)]);
  const shaObj = sha224.create();
  shaObj.update(array);
  const hash = new Uint8Array(shaObj.array());
  const checksum = to32bits(crc32Number(hash));
  return [...checksum, ...hash];
}

export function principalToAddress(principal: Principal, subaccount: number | number[] | undefined = 0): string {
  return toHexString(principalToAddressBytes(principal, subaccount));
}

export function getSubAccountArray(subaccount: number | number[]) {
  if (Array.isArray(subaccount)) {
    return subaccount.concat(Array(32 - subaccount.length).fill(0));
  } else {
    return Array(28)
      .fill(0)
      .concat(to32bits(subaccount ? subaccount : 0));
  }
}
