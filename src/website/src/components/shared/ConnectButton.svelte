<script>
  import { dialog } from "../../store/dialog";
  import ConnectDialog from "./ConnectDialog.svelte";
</script>

<button on:click={() => $dialog.open()}> Connect </button>
<ConnectDialog />
