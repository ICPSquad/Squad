<script lang="ts">
  import { fade } from "svelte/transition";
  import { fly } from "svelte/transition";
  export let message = "";
  export let state: "error" | "success" | "waiting" | "neutral" = "neutral";

  function stateToClass(): string {
    switch (state) {
      case "error":
        return "toast error";
      case "success":
        return "toast success";
      case "waiting":
        return "toast waiting";
      case "neutral":
        return "toast neutral";
    }
  }
</script>

{#if message}
  <div transition:fly={{ y: 200, opacity: 1 }} class={stateToClass()}>
    {message}
  </div>
{/if}

<style lang="scss">
  @use "../../styles/" as *;

  .toast {
    z-index: 999;
    position: fixed;
    bottom: 0;
    left: 0;
    width: 100%;
    padding: 40px 20px;
    background-color: $verydarkgrey;
    color: $white;
    font-size: x-large;
    font-weight: bold;
    text-align: center;
    transition: height 2s;
    border-top-left-radius: 32px;
    border-top-right-radius: 32px;
  }

  .error {
    background-color: $pink;
    color: $white;
  }

  .success {
    background-color: $green;
    color: $white;
  }

  .neutral {
    background-color: $verydarkgrey;
    color: $white;
  }

  .waiting {
    background-color: $verydarkgrey;
    color: $white;
  }
</style>
