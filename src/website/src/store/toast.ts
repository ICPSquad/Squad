import { timeout } from "@dfinity/agent/lib/cjs/polling/strategy";
import { writable, get } from "svelte/store";
import type { ToastState } from "./types/toast-store";

export const toast = writable<ToastState>({
  state: "info",
  message: "",
  timeout: undefined,
});

export function setMessage(message: string, state: "error" | "success" | "waiting" | "info", time?: number) {
  // Remove the previous timeout if it exists to prevent conflict between previous timeout executed.
  let id = get(toast).timeout;
  if (id) {
    clearTimeout(id);
  }
  let timeoutId;
  // Set the new timeout if it is defined.
  if (time) {
    timeoutId = setTimeout(() => {
      toast.set({
        state: "info",
        message: "",
      });
    }, time);
  }
  // Set the new state.
  toast.set({
    state,
    message,
    timeout: timeoutId,
  });
}
