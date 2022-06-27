<script>
  import { dialog } from "../../store/dialog";
  import ConnectDialog from "./ConnectDialog.svelte";

  export let message = "Sign in";
</script>

<button on:click={() => $dialog.open()}> {message} </button>
<ConnectDialog />
