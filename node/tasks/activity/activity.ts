import { hubActor } from "../../actor";
import { fetchIdentity } from "../../keys";
import { CapRoot } from "@psychedelic/cap-js";
import type { Event } from "@psychedelic/cap-js";
import { Principal } from "@dfinity/principal";
import { principalToAddress } from "../../tools/principal";
import type { Activity } from "@canisters/hub/hub.did.d";
import { avatarActor } from "../../actor";
import { writeFileSync, readFileSync, write } from "fs";
import type internal from "stream";

const BEGIN_TIME = 1655729084018865799;

// async function getAllCollections() {
//   let identity = fetchIdentity("admin");
//   let actor = await hubActor(identity);
//   let collections = await actor.get_all_collections();
// }

async function getActivity() {
  let metrics: [Principal, bigint, bigint, bigint, bigint, bigint, bigint][] = []; //[principal, activity]
  let identity = fetchIdentity("admin");
  let avatar = avatarActor(identity);
  let data = await avatar.get_infos_accounts();
  // Collect ALL events from all registered collections!
  let hub = await hubActor(identity);
  let collections = await hub.get_all_collections();
  let events = [];
  for (let collection of collections) {
    if (collection[1].toString() == "qfevy-hqaaa-aaaaj-qanda-cai") {
      let new_events = await collectEvents(BEGIN_TIME, collection[1]);
      events = events.concat(new_events);
    }
    // console.log("Collected " + new_events.length + " events from " + collection[1].toString());
  }
  console.log("Total number of events : " + events.length);
  data.forEach((info) => {
    let principal = info[0];
    let account = info[1];
    let buy: [bigint, bigint] = [BigInt(0), BigInt(0)];
    let sell: [bigint, bigint] = [BigInt(0), BigInt(0)];
    let activity = {
      buy,
      burn: BigInt(0),
      mint: BigInt(0),
      sell,
      collection_involved: BigInt(0),
      accessory_minted: BigInt(0),
      accessory_burned: BigInt(0),
    };
    events.forEach((event) => {
      if (event.operation == "sale" || event.operation == "Sale") {
        let data_sale = getDetails(event);
        // A sell
        if (data_sale[0] == account) {
          activity.sell[0]++;
          activity.sell[1] = BigInt(BigInt(data_sale[2]) + activity.sell[1]);
        }
        // A buy
        if (data_sale[1] == account) {
          activity.buy[0]++;
          activity.buy[1] = BigInt(BigInt(data_sale[2]) + activity.buy[1]);
        }
      }
      if ((event.operation == "mint" || event.operation == "Mint") && event.caller.toString() == principal.toString()) {
        activity.mint++;
      }
      if ((event.operation == "burn" || event.operation == "Burn") && event.caller.toString() == principal.toString()) {
        activity.burn++;
      }
    });
    metrics.push([principal, activity.buy[0], activity.buy[1], activity.sell[0], activity.sell[1], activity.mint, activity.burn]);
  });
  writeFileSync(`user_metrics.csv`, metrics.join("\n"));
}

function getDetails(event: Event): [string, string, number] {
  let details = event.details;
  var from = "";
  var to = "";
  var price = 0;
  let length = details.length;
  for (let i = 0; i < length; i++) {
    if (details[i][0] == "from") {
      from = details[i][1].Text;
    }
    if (details[i][0] == "to") {
      to = details[i][1].Text;
    }
    if (details[i][0] == "price") {
      price = details[i][1].U64;
    }
  }
  return [from, to, price];
}

function isEventRelated(p: Principal, account: string, event: Event): boolean {
  if (event.caller.toString() == p.toString()) {
    return true;
  }
  let details = event.details;
  let length = details.length;
  for (let i = 0; i < length; i++) {
    if (details[i][0] == "from" && details[i][1] == account) {
      return true;
    }
    if (details[i][0] == "to" && details[i][1] == account) {
      return true;
    }
  }
  return false;
}

async function collectAllEvents() {
  let identity = fetchIdentity("admin");
  let actor = await hubActor(identity);
  let collections = await actor.get_all_collections();
  for (let collection of collections) {
    const capRoot = await CapRoot.init({
      canisterId: collection[1].toString(),
      host: "https://ic0.app",
    });
    const events = await capRoot.get_transactions({
      page: 0,
      witness: false,
    });
  }
}

async function showPage(n: number, root_cid: Principal) {
  const capRoot = await CapRoot.init({
    canisterId: root_cid.toString(),
    host: "https://ic0.app",
  });
  let result = await capRoot.get_transactions({
    page: n,
    witness: false,
  });
  console.log(result.data);
}

async function collectEvents(time: Number, root_cid: Principal): Promise<Event[]> {
  const capRoot = await CapRoot.init({
    canisterId: root_cid.toString(),
    host: "https://ic0.app",
  });
  var all_events: Event[] = [];
  let keep_going = true;
  let latest_page = await getLatestPage(root_cid);
  while (keep_going && latest_page >= 0) {
    let result = await capRoot.get_transactions({
      page: latest_page,
      witness: false,
    });
    let events = result.data;
    events.forEach((event) => {
      if (Number(event.time) * 1_000_000 > time) {
        all_events.push(event);
      } else {
        keep_going = false;
      }
    });
    latest_page--;
  }
  return all_events;
}

async function getLatestPage(root_cid: Principal): Promise<number> {
  const capRoot = await CapRoot.init({
    canisterId: root_cid.toString(),
    host: "https://ic0.app",
  });
  let size = await capRoot.size();
  let latest_page = Math.floor(Number(size) / 64);
  console.log("Latest page", latest_page);
  return latest_page;
}

async function getBurnEvents(): Promise<Event> {
  let events = await collectEvents(BEGIN_TIME, Principal.fromText("qfevy-hqaaa-aaaaj-qanda-cai"));
  events = events.filter((event) => {
    return event.operation === "burn";
  });
  console.log(events);
  return events;
}

async function getEventsFrom(p: Principal): Promise<Event> {
  let events = await collectEvents(BEGIN_TIME, Principal.fromText("qfevy-hqaaa-aaaaj-qanda-cai"));
  events = events.filter((event) => {
    return event.caller.toString() == p.toString();
  });
  return events;
}

async function getMetrics(p: Principal): Promise<[number, number]> {
  let events = await collectEvents(BEGIN_TIME, Principal.fromText("qfevy-hqaaa-aaaaj-qanda-cai"));
  var nb_accessory_minted = 0;
  var nb_accessory_burned = 0;
  let account = principalToAddress(p, 0);
  events.forEach((event) => {
    if (event.operation == "mint" && event.caller.toString() == p.toString()) {
      nb_accessory_minted++;
    }
    if (isAccessoryBurnEvent(account, event)) {
      nb_accessory_burned++;
    }
  });
  console.log(nb_accessory_minted, nb_accessory_burned);
  return [nb_accessory_minted, nb_accessory_burned];
}

function isAccessoryBurnEvent(account: string, event: Event): boolean {
  return isEventFrom(account, event) && event.operation == "burn";
}

function isEventFrom(account: string, event: Event): boolean {
  let details = event.details;
  let length = details.length;
  for (let i = 0; i < length; i++) {
    if (details[i][0] == "from") {
      return details[i][1] == account;
    }
  }
  return false;
}

getActivity();
