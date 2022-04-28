import { getAccountIdentifier } from "../account";
import { Principal } from "@dfinity/principal";

try {
  let principal = process.argv[2];
  console.log(getAccountIdentifier(Principal.fromText(principal)));
} catch (error) {
  console.log(error);
}
