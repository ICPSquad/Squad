import { fetchIdentity, generateKey } from "../keys";

try {
  generateKey("admin");
} catch {
  // ignore
}
console.log(fetchIdentity("admin").getPrincipal().toText());
