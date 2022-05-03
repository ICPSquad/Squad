import type { Identity } from "@dfinity/agent";
import { Ed25519KeyIdentity } from "@dfinity/identity";
import { existsSync, mkdirSync, readFileSync, writeFileSync } from "fs";

export const DIR = `${__dirname}/../keys`;
export const PATH = `${DIR}/keys.json`;

export function generateKey(name: string): Identity {
  if (!existsSync(PATH)) mkdirSync(DIR, { recursive: true });
  if (!existsSync(PATH)) writeFileSync(PATH, "{}", { flag: "wx" });

  const keys = JSON.parse(readFileSync(PATH).toString());
  if (!keys[name]) {
    const key = Ed25519KeyIdentity.generate();
    keys[name] = JSON.stringify(key);
    writeFileSync(PATH, JSON.stringify(keys));
    return key;
  }
  throw Error(`Key already exists for name : ${name}`);
}

export function fetchIdentity(name: string): Identity {
  if (!existsSync(PATH)) throw Error(`No keys found at ${PATH}`);
  const keys = JSON.parse(readFileSync(PATH).toString());
  if (!keys[name]) throw Error(`No key found for name : ${name}`);
  return Ed25519KeyIdentity.fromParsedJson(JSON.parse(keys[name]));
}
