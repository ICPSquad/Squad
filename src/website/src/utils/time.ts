export function unixTimeToDate(unixTime: number): string {
  // Convert nanoseconds to milliseconds
  const date = new Date(unixTime / 1000 / 1000);
  return date.toLocaleString();
}
