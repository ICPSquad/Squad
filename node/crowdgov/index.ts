import "isomorphic-fetch";

async function getAllGovernanceProposalsIds(): Promise<Array<number>> {
  var proposals_ids = [];
  var offset = 0;
  var keep = true;
  while (keep) {
    const res = await fetch(`https://ic-api.internetcomputer.org/api/v3/proposals?max_proposal_index=564&offset=${offset}&limit=100&include_topic=TOPIC_GOVERNANCE`);
    const json = await res.json();
    for (var i = 0; i < json.data.length; i++) {
      proposals_ids.push(json.data[i].proposal_id);
    }
    if (json.data.length < 100) {
      keep = false;
    }
    offset += 100;
  }
  return proposals_ids;
}

async function doJob() {
  await getAllGovernanceProposalsIds().then((res) => console.table(res));
}

async function getKnownNeuronsVotes(proposal_id: number) {
  const res = await fetch(`https://ic-api.internetcomputer.org/api/v3/proposals/${proposal_id}`);
  const json = await res.json();
  const votes = json.known_neurons_ballots;
  console.log("Votes for proposal " + proposal_id + ": " + votes);
}

doJob();

getKnownNeuronsVotes(352);
