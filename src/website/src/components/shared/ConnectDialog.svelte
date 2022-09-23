<script lang="ts">
  import { plugConnection, stoicConnexion, infinityConnection } from "@src/utils/connection";
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

  async function handleConnexion(name: string) {
    if (name === "Stoic") {
      try {
        await stoicConnexion();
        close();
      } catch (e) {
        alert("Failed to connect with Stoic.");
        console.log("Error connecting to Stoic", e);
      }
    } else if (name === "Plug") {
      if (mobileCheck()) {
        alert("Plug wallet is not supported on mobile devices for now. Please use another wallet provider.");
        return;
      }
      try {
        await plugConnection();
        close();
      } catch (e) {
        alert("Failed to connect with Plug. Make sure you have the corresponding extension installed.");
        console.log("Error connecting to Plug", e);
      }
    } else if (name === "Infinity") {
      if (mobileCheck()) {
        alert("Infinity wallet is not supported on mobile devices for now. Please use another wallet provider.");
        return;
      }
      try {
        await infinityConnection();
        close();
      } catch (e) {
        alert("Failed to connect with this wallet. Make sure you have the corresponding extension installed.");
        console.log("Error connecting to InfinityWallet", e);
      }
    }
  }

  function mobileCheck(): boolean {
    let check = false;
    (function (a) {
      if (
        /(android|bb\d+|meego).+mobile|avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|iris|kindle|lge |maemo|midp|mmp|mobile.+firefox|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\.(browser|link)|vodafone|wap|windows ce|xda|xiino/i.test(
          a
        ) ||
        /1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|yas\-|your|zeto|zte\-/i.test(
          a.substr(0, 4)
        )
      )
        check = true;
    })(
      //@ts-ignore
      navigator.userAgent || navigator.vendor || window.opera
    );
    return check;
  }
</script>

{#if $dialog.isOpen}
  <div class="dialog-styles dark" on:click={close}>
    <div class="dialog-container">
      <h3>Connect a wallet</h3>
      <div>
        <button on:click={() => handleConnexion("Plug")} class={`button-styles`}>
          <img class="img-styles" src={`assets/plugLight.svg`} alt="Plug Logo" />
          <div>
            <span class="button-label">Plug wallet</span>
          </div>
        </button>
        <button on:click={() => handleConnexion("Stoic")} class={`button-styles`}>
          <img class="img-styles" src={`assets/stoic.png`} alt="Stoic Logo" />
          <div>
            <span class="button-label">Stoic wallet</span>
          </div>
        </button>
        <button on:click={() => handleConnexion("Infinity")} class={`button-styles`}>
          <img class="img-styles" src={`assets/infinity.png`} alt="Infinity Logo" />
          <div>
            <span class="button-label">Infinity wallet</span>
          </div>
        </button>
      </div>
    </div>
  </div>
{/if}

<style>
  h3 {
    text-align: center;
    margin: 10px 0;
  }

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

  @-webkit-keyfraxmes fade-out {
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
