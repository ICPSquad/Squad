<script>
  import { fade } from "svelte/transition";
  import { fly } from "svelte/transition";
  export let message = "";
</script>

{#if message}
  <div transition:fly={{ y: 200, opacity: 1 }} class="toast">
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
    background-color: $green;
    color: $black;
    text-align: center;
    transition: height 2s;
    border-top-left-radius: 32px;
    border-top-right-radius: 32px;
  }
</style>
