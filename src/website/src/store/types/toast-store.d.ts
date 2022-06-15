export type ToastState = {
  state: "error" | "success" | "waiting" | "info";
  message: string;
  timeout?: number;
};
