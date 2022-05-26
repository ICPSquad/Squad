export type State =
  | "creating-accessory"
  | "waiting-wallet-connection"
  | "waiting-inventory"
  | "verification"
  | "waiting-invoice"
  | "waiting-payment"
  | "waiting-payment-processing"
  | "waiting-mint"
  | "accessory-minted"
  | "error"
  | "missing-materials";
