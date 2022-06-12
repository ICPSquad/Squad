import type { Mission, Reward } from "@canisters/hub/hub.did.d";

export function getRewardToString(mission: Mission): string {
  const reward = mission.rewards[0];
  const text = reward.Points.toString() + " points";
  return text;
}
