<script lang="ts">
  import { fly } from "svelte/transition";
  import { setMessage, toast } from "@src/store/toast";
</script>

{#if $toast.message}
  <div transition:fly={{ y: 200, opacity: 1 }} class={"toast " + $toast.state}>
    {$toast.message}
    <div class="cross" on:click={() => setMessage("", "info")}>x</div>
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

  .cross {
    position: absolute;
    font-size: x-large;
    top: 0;
    right: -10;
    padding: 10px;
    cursor: pointer;
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
    background-color: $grey;
    color: $white;
  }

  .waiting {
    background-color: $grey;
    color: $white;
    animation: pulse 3s linear infinite;
  }

  @keyframes pulse {
    0% {
      opacity: 0.5;
    }
    50% {
      opacity: 1;
    }
    100% {
      opacity: 0.5;
    }
  }
</style>
