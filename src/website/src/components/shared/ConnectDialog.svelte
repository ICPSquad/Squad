<script lang="ts">
  import { plugConnection, stoicConnexion } from "@src/utils/connection";
  import { onMount } from "svelte";
  import { get } from "svelte/store";
  import { dialog } from "../../store/dialog";

  const close = () => {
    get(dialog).close();
  };

  onMount(() => {
    const handleEsc = (e) => {
      if (e.keyCode === 27) {
        close();
      }
    };
    window.addEventListener("keydown", handleEsc);
    return () => {
      window.removeEventListener("keydown", handleEsc);
    };
  });
</script>

{#if $dialog.isOpen}
  <div class="dialog-styles dark" on:click={close}>
    <div class="dialog-container">
      <div>
        <button on:click={() => plugConnection()} class={`button-styles`}>
          <img class="img-styles" src={`assets/plugLight.svg`} alt="Plug Logo" />
          <div>
            <span class="button-label">Plug wallet</span>
          </div>
        </button>
        <button on:click={() => stoicConnexion()} class={`button-styles`}>
          <img class="img-styles" src={`assets/stoic.png`} alt="Stoic Logo" />
          <div>
            <span class="button-label">Stoic wallet</span>
          </div>
        </button>
      </div>
    </div>
  </div>
{/if}

<style>
  .dialog-styles span {
    font-family: -apple-system, BlinkMacSystemFont, "Arial", "Helvetica Neue", sans-serif;
  }

  .img-styles {
    height: 55px;
    width: 55px;
    padding: 10px;
    box-sizing: content-box;
  }

  @media all and (max-width: 300px) {
    .img-styles {
      width: 11vw;
      max-height: 11vw;
      height: auto;
      padding: 0;
      padding-right: 5px;
    }
  }

  .dialog-styles {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    z-index: 999;
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    background: rgb(0 0 0 / 60%);
    animation: fade-in 0.18s;
    backdrop-filter: blur(5px);
    cursor: pointer;
    overflow: auto;
    box-sizing: border-box;
    padding: 30px;
  }

  .dialog-container {
    display: grid;
    grid-gap: 5px;
    padding: 10px;
    background: #f4f4f4;
    border-radius: 15px;
    overflow: auto;
    grid-template-columns: 1fr;
    cursor: initial;
    animation: move-in 0.18s;
    max-width: 420px;
    width: 100%;
    box-sizing: border-box;
  }

  .dark .dialog-container {
    background: rgb(35 35 39);
  }

  @keyframes fade-in {
    from {
      opacity: 0;
    }
    to {
      opacity: 1;
    }
  }

  @keyframes move-in {
    from {
      transform: translateY(5%);
    }
    to {
      transform: translateY(0%);
    }
  }

  @-webkit-keyframes fade-out {
    0% {
      opacity: 1;
    }
    100% {
      opacity: 0;
    }
  }

  .button-styles {
    background: transparent;
    max-width: 100%;
    width: 100%;
    height: 75px;
    padding: 10px;
    border: none;
    border-radius: 11px;
    outline: 0;
    cursor: pointer;
    transition: transform 0.15s;
    display: flex;
    align-items: center;
  }

  .dark .button-styles {
    border: none;
  }

  .button-label {
    margin-top: 10px;
    margin-bottom: 10px;
    font-size: 21px;
    font-weight: 300;
    color: #424242;
    text-align: left;
  }

  .dark .button-label {
    color: white;
  }

  @media all and (max-width: 300px) {
    .button-label {
      font-size: 6vw;
    }
  }

  .button-styles:hover {
    transform: scale(1.02);
    font-weight: 800 !important;
    transition: all 0.2s;
    background: white;
  }

  .dark .button-styles:hover {
    background: #545454;
  }

  .button-styles > div {
    display: flex;
    padding: 0 15px;
    border-radius: 10px;
    font-weight: 400;
    height: 100%;
    flex-direction: column;
    align-items: flex-start;
    justify-content: center;
  }

  .connect-button {
    font-size: 18px;
    background: rgb(35 35 39);
    color: white;
    border: none;
    padding: 10px 20px;
    display: flex;
    align-items: center;
    border-radius: 40px;
    cursor: pointer;
  }

  .connect-button:hover {
    transform: scale(1.03);
    transition: all 0.4s;
  }
</style>