export type State =
  | "creating-avatar"
  | "waiting-wallet-connection"
  | "waiting-invoice"
  | "waiting-payment"
  | "waiting-payment-processing"
  | "waiting-mint"
  | "avatar-minted";
  | "error";
