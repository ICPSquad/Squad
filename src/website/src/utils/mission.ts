import type { MissionStatus, Mission } from "@canisters/hub/hub.did.d";

export function missionStatusToText(status: MissionStatus): string {
  if ("Running" in status) {
    return "Running";
  }
  if ("Ended" in status) {
    return "Ended";
  }
  if ("Pending" in status) {
    return "Pending";
  } else {
    return "Unknown";
  }
}

export function categoryToMission(category: string, missions: Mission[]): Mission[] {
  if (category === "ended") {
    // Only keep mission where they have a status of "Ended"
    return missions.filter((mission) => {
      return missionStatusToText(mission.status) === "Ended";
    });
  } else if (category === "pending") {
    // Only keep mission where they have a status of "Pending"
    return missions.filter((mission) => {
      return missionStatusToText(mission.status) === "Pending";
    });
  }
  // Only keep missions which include a tag with the given category and status is "Running"
  return missions.filter((mission) => {
    return mission.tags.includes(category) && missionStatusToText(mission.status) === "Running";
  });
}
