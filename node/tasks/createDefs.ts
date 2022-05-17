import Papa from "papaparse";
import { createReadStream, writeFileSync, appendFileSync, readFileSync, mkdirSync, existsSync } from "fs";

console.log("Creating the definitons for all components");

const DIR_ASSETS = `${__dirname}/../../assets`;

const DIR = `${__dirname}/../../src/website/assets`;
const PATH = `${__dirname}/../../src/website/src/components/AvatarComponentsSvg.svelte`;

const csv_string = readFileSync(`${DIR_ASSETS}/components/manifest-components.csv`, "utf8").toString();
const csv_parsed = Papa.parse(csv_string, {
  delimiter: ",",
});


function createDefs() {
  if (!existsSync(PATH)) mkdirSync(DIR, { recursive: true });
  if (!existsSync(PATH)) writeFileSync(PATH, "", { flag: "wx" });

  writeFileSync(PATH, "<svg version=" + '"1.1"' + " xmlns=" + '"http://www.w3.org/2000/svg"' +" viewBox=" + '"0 0 800 800"'  +" class=" + '"h-0"' + ">");
  appendFileSync(PATH, "<defs>");
  //@ts-ignore
  let length = csv_parsed.data.length;
  for (let i = 1; i < length; i++) {
    let result = csv_parsed.data[i];
    const category = result[0];
    const type = result[1];
    const name = result[2];
    const layers = result[3].split("/");
    layers.forEach((layer) => {
      let file = readFileSync(`${DIR_ASSETS}/components/${category}/${type}/${name}/${name}-${layer}.svg`);
      let content = file.toString();
      appendFileSync(PATH, '<g id="' + name + "-" + layer + '">');
      appendFileSync(PATH, content);
      appendFileSync(PATH, "</g>");
    });
  }
  appendFileSync(PATH, "</defs>");
  appendFileSync(PATH, "</svg>");
}

createDefs();

console.log("Done");

