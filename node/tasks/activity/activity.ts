import { hubActor } from "../../actor";
import { fetchIdentity } from "../../keys";
import { CapRoot } from "@psychedelic/cap-js";
import type { Event } from "@psychedelic/cap-js";
import { Principal } from "@dfinity/principal";
import { principalToAddress } from "../../tools/principal";
import type { Activity, Collection, ExtendedEvent } from "@canisters/hub/hub.did.d";

const BEGIN_TIME = 1655729084018865799;

async function collectAllEvents(): Promise<ExtendedEvent[]> {
  let identity = fetchIdentity("admin");
  let hub = await hubActor(identity);
  let collections = await hub.get_registered_cids();
  let all_events: ExtendedEvent[] = [];
  for (let collection of collections) {
    let new_events = await collectEvents(BEGIN_TIME, collection[1]);
    new_events = new_events.map((e) => _extendEvent(e, collection[0].contractId));
    new_events = new_events.filter((e) => _keepEvent(e));
    console.log("Collected " + new_events.length + " events from " + collection[0].name);
    all_events.push(...new_events);
  }
  if (all_events.length > 0) {
    return all_events;
  } else {
    throw new Error("No events found!");
  }
}

function _extendEvent(e: Event, collection: Principal): ExtendedEvent {
  return {
    ...e,
    collection: collection,
  };
}

function _keepEvent(e: Event): boolean {
  return e.operation == "burn" || e.operation == "mint" || e.operation == "sale";
}

function _isEventRelated(p: Principal, e: Event): boolean {
  if (e.caller.toString() == p.toString()) {
    return true;
  }
  switch (e.operation) {
    case "burn":
      return false;
    case "mint":
      return false;
    case "sale":
      let account = principalToAddress(p, 0);
      let details = _getDetails(e);
      return details[0] == account || details[1] == account;
  }
}

async function doJob() {
  let identity = fetchIdentity("admin");
  let hub = await hubActor(identity);
  let events = await collectAllEvents();
  let principal_test = Principal.fromText("udmjf-fyc6j-f7dnl-dw5bh-hh4wg-ln7iy-36pgp-mjocm-my4vc-r2irg-2ae");
  let events_related = events.filter((e) => _isEventRelated(principal_test, e));
  let result = await hub.populate_events(principal_test, events_related);
  console.log("Done", result);
}

function addToCollectionInvolved(collection: Collection, collection_involved: Collection[]) {
  let is_already_there = false;
  for (let c of collection_involved) {
    if (c[0].name == collection[0].name) {
      is_already_there = true;
    }
  }
  if (!is_already_there) {
    collection_involved.push(collection);
  }
}

function _getDetails(event: Event): [string, string, number] {
  let details = event.details;
  var from = "";
  var to = "";
  var price = 0;
  let length = details.length;
  for (let i = 0; i < length; i++) {
    if (details[i][0] == "from") {
      if (details[i][1].hasOwnProperty("Text")) {
        from = details[i][1].Text;
      } else if (details[i][1].hasOwnProperty("Principal")) {
        from = details[i][1].Principal.toString();
      } else {
        console.log("Unknown from type: " + JSON.stringify(details[i][1]));
      }
    }
    if (details[i][0] == "to") {
      if (details[i][1].hasOwnProperty("Text")) {
        to = details[i][1].Text;
      } else if (details[i][1].hasOwnProperty("Principal")) {
        to = details[i][1].Principal.toString();
      } else {
        console.log("Unknown to type: " + JSON.stringify(details[i][1]));
      }
    }
    if (details[i][0] == "price") {
      price = details[i][1].U64;
    }
  }
  return [from, to, price];
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
      if (Number(event.time) * 1_000_000 > time && keep_going) {
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
  let latest_page = Math.floor(Number(size) / 64) + 1;
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

doJob();
