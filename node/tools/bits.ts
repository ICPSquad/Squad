export function to32bits(num: number): number[] {
  let b = new ArrayBuffer(4);
  new DataView(b).setUint32(0, num);
  return Array.from(new Uint8Array(b));
}

export function from32bits(bytes: number[]): number {
  let value;
  for (let i = 0; i < 4; i++) {
    // @ts-ignore
    value = (value << 8) | bytes[i];
  }
  if (value === undefined) {
    throw new Error(`Could not decode number from bytes: ${bytes.join(" ")}`);
  }
  return value;
}

export function toHexString(bytes: number[]): string {
  return Array.from(bytes, function (byte) {
    return ("0" + (byte & 0xff).toString(16)).slice(-2);
  }).join("");
}
