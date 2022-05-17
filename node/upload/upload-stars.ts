import { fetchIdentity } from "../keys";
import { avatarActor } from "../actor";
import csvParser from "csv-parser";
import { createReadStream } from "fs";
import type {Name, Stars, Stats} from "../declarations/avatar/avatar.did.d"

var results: Array<any> = [];
createReadStream(`${__dirname}/../../assets/cards/manifest-stars.csv`)
    .pipe(csvParser())
    .on("data", (data) => {
        results.push(data);
    })
    .on("end", () => {
        console.log("res", results);
        upload();
    }
);

async function upload() {
    let identity = fetchIdentity("admin");
    let actor = avatarActor(identity);
    let size = results.length;
    var stats : Stats = [];
    for (let i = 0; i < size; i++) {
        let element = results[i];
        stats.push([element.name, BigInt(element.stars)]);
    }
    console.log("stats", stats);
    let result = await actor.uploadStats(stats);
    console.log("result", result);
}