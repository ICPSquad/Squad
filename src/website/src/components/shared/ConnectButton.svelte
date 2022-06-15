<script>
  import { dialog } from "../../store/dialog";
  import ConnectDialog from "./ConnectDialog.svelte";

  export let message = "Connect";
</script>

<button on:click={() => $dialog.open()}> {message} </button>
<ConnectDialog />
