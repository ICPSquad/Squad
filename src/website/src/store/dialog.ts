import { writable } from "svelte/store";
import type { DialogStore } from "./types/dialog-store";

export const dialog = writable<DialogStore>({
  isOpen: false,
  open: () => {
    dialog.update((d) => ({ ...d, isOpen: true }));
  },
  close: () => {
    dialog.update((d) => ({ ...d, isOpen: false }));
  },
});
