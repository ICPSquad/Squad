import { hubActor } from "../actor";
import { readFileSync } from "fs";
import { fetchIdentity } from "../keys";

const canisters =
  process.env.NODE_ENV === "production"
    ? JSON.parse(readFileSync(`${__dirname}/../../canister_ids.json`).toString())
    : JSON.parse(readFileSync(`${__dirname}/../../.dfx/local/canister_ids.json`).toString());

const hubID = process.env.NODE_ENV === "production" ? canisters.hub.ic : canisters.hub.local;
const network = process.env.NODE_ENV === "production" ? "ic" : "local";

async function getTotalStyleScore() {
  let identity = fetchIdentity("admin");
  let actor = hubActor(identity);
  let leaderboard_opt = await actor.get_specified_leaderboard(BigInt(1));
  let leaderboard = leaderboard_opt[0];
  let total = 0;
  for (let i = 0; i < leaderboard.length; i++) {
    let style_score_opt = leaderboard[i][3];
    if (style_score_opt.length > 0) {
      total += Number(style_score_opt[0]);
    }
  }
  console.log("Total style score : " + total);
}

getTotalStyleScore();
