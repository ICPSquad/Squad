import { avatarActor } from "../actor";
import { writeFileSync, readFileSync } from "fs";
import { fetchIdentity } from "../keys";

const canisters =
  process.env.NODE_ENV === "production"
    ? JSON.parse(readFileSync(`${__dirname}/../../canister_ids.json`).toString())
    : JSON.parse(readFileSync(`${__dirname}/../../.dfx/local/canister_ids.json`).toString());

async function getData() {
  let identity = fetchIdentity("admin");
  let actor = avatarActor(identity);
  let users = await actor.get_all_users();
  console.log(users);
  let data = [];
  users.forEach((user) => {
    data.push([user[0].toString(), user[1].twitter, user[1].email, user[1].discord]);
  });
  writeFileSync(`user_data.csv`, data.join("\n"));
}

getData();
