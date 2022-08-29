import { CapRoot } from "@psychedelic/cap-js";
import type { Event, DetailValue } from "@psychedelic/cap-js";
import { Principal } from "@dfinity/principal";
import type { DetailType } from "@psychedelic/dab-js/dist/interfaces/dab_registries/registry_standard";
import { writeFileSync } from "fs";

const BEGIN_TIME = 1655729084018865799;
const MATERIALS = ["Cloth", "Wood", "Glass", "Metal", "Circuit", "Dfinity-stone"];

async function collectEvents(time: Number, root_cid: Principal): Promise<Event[]> {
  const capRoot = await CapRoot.init({
    canisterId: root_cid.toString(),
    host: "https://ic0.app",
  });
  var all_events: Event[] = [];
  let keep_going = true;
  let latest_page = await getLatestPage(root_cid);
  while (keep_going && latest_page >= 0) {
    console.log("Page", latest_page);
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

async function writeBurnEvents() {
  let events = await collectEvents(BEGIN_TIME, Principal.fromText("qfevy-hqaaa-aaaaj-qanda-cai"));
  events = events.filter((event) => {
    return event.operation === "burn";
  });
  let metrics: [string, number, string, string, string, string][] = [];
  events.forEach((event) => {
    let operation = event.operation;
    let time = Number(event.time) * 1_000_000;
    let caller = event.caller.toString();
    let token = _getValue(event, "token");
    let from = _getValue(event, "from");
    let name = _getValue(event, "name");
    if (!MATERIALS.includes(name)) {
      metrics.push([operation, time, caller, token, from, name]);
    }
  });
  writeFileSync("burn.csv", metrics.join("\n"));
}

function _getValue(e: Event, key: string): string {
  let details = e.details;
  var value = "";
  for (let i = 0; i < details.length; i++) {
    let detail = details[i];
    if (detail[0] === key) {
      value = decodeDetailValue(details[i][1]) as string;
    }
  }
  return value;
}

const decodeDetailValue = (value: DetailValue): DetailType => {
  const type = Object.keys(value)?.[0];
  switch (type) {
    case "Vec":
      // Non supported
      return false;
    case "True":
      return true;
    case "False":
      return false;
    default:
      return value[type];
  }
};

writeBurnEvents();
