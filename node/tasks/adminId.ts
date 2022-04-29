import { fetchIdentity, generateKey } from "../keys";

try {
  fetchIdentity("admin");
} catch {
  throw new Error("Error fetching admin key.");
}
