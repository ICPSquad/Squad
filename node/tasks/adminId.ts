import { fetchIdentity, generateKey } from "../keys";

console.log(fetchIdentity("admin").getPrincipal().toString());
