type Stats = [string, bigint, [] | bigint, [] | [bigint]]; // (Name, Supply, FloorPrice, LastPrice)
type Supply = number | null;
type LastPrice = number | null;
export function nameToStats(stats: Stats | undefined, name: string): [Supply, LastPrice] {
  if (stats === undefined) {
    return [null, null];
  }
  const stat = stats.find((s) => s[0] === name);
  if (stat === undefined) {
    return [null, null];
  } else {
    let statistic = [Number(stat[1]), e8sToICP(stat[2])];
    //@ts-ignore
    return statistic;
  }
}

export function e8sToICP(e8s: [bigint] | []): number | null {
  if (e8s.length === 0) {
    return null;
  } else {
    let result = Number(e8s[0]) / 100_000_000;
    let result_round = Math.round(result * 1000) / 1000;
    return result_round;
  }
}
