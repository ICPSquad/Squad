<script lang="ts">
  import type { Invoice__1 as Invoice } from "@canisters/invoice/invoice.did.d";
  import type { State } from "@src/components/create-avatar/types";
  import { plugConnection } from "@src/utils/connection";
  import { user } from "@src/store/user";
  import { get } from "svelte/store";
  import { mintRequest } from "@utils/mint";
  import { createInvoice } from "@utils/invoice";
  import { payInvoice } from "@utils/payment";
  import Spinner from "./Spinner.svelte";
  import Link from "@components/shared/Link.svelte";
  import type { AvatarComponents } from "@src/types/avatar.d";
  import type { AvatarColors } from "@src/types/color.d";

  export let state: State;
  export let setState: (newState: State) => void;

  export let colors: AvatarColors | undefined;
  export let components: AvatarComponents | undefined;

  let invoice: Invoice | undefined = undefined;
  let error_message: string | undefined;
  let token_identifier: string | undefined;

  async function handleConnectPlug() {
    await plugConnection();
    setState("waiting-invoice");
  }

  // const handleConnectStoic = () => {
  //   await stoic
  //   setState("waiting-invoice");
  // };

  $: if (state === "waiting-invoice") {
    handleInvoice();
  }

  const handleInvoice = async () => {
    invoice = await createInvoice("AvatarMint");
    setState("waiting-payment");
  };

  const handlePayment = async () => {
    setState("waiting-payment-processing");
    if (!invoice) {
      throw new Error("Invoice is not defined");
    }
    const { wallet: Wallet } = get(user);
    if (!Wallet) {
      throw new Error("Wallet is not defined");
    }
    try {
      const result = await payInvoice(invoice, Wallet);
      if (result.height > 0) {
        setState("waiting-mint");
      } else {
        setState("error");
        error_message = "Payment failed";
      }
    } catch (error) {
      setState("error");
      error_message = "Payment was rejected.";
    }
  };

  const handlePreorder = () => {
    if (
      confirm(
        "If you joined the preorder list but never minted your avatar, you can skip payment. This won't work otherwise. \n\nDo you confirm being part of the preorder ?"
      )
    ) {
      setState("waiting-mint");
    }
  };

  $: if (state === "waiting-mint") {
    handleMint();
  }

  const handleMint = async () => {
    const result = await mintRequest(
      components,
      colors,
      invoice ? Number(invoice.id) : undefined
    );
    if ("ok" in result) {
      token_identifier = result.ok;
      setState("avatar-minted");
    } else {
      setState("error");
      error_message = result.err;
    }
  };

  const handleDownload = () => {
    fetch(
      "https://jmuqr-yqaaa-aaaaj-qaicq-cai.raw.ic0.app/tokenid=" +
        token_identifier
    )
      .then((response) => response.blob())
      .then((blob) => {
        const url = window.URL.createObjectURL(blob);
        const a = document.createElement("a");
        a.href = url;
        a.download = "Avatar.svg";
        a.click();
      });
  };
</script>

<div class="checkout">
  <h3>Mint your avatar</h3>
  {#if state === "waiting-wallet-connection"}
    <p>Please connect a wallet to continue</p>
    <button on:click={() => handleConnectPlug()}>Plug wallet</button>
    <!-- <button on:click={() => handleConnectStoic()}>Stoic wallet</button> -->
    <div class="back" on:click={() => setState("creating-avatar")}>← Back</div>
  {:else if state === "waiting-invoice"}
    <Spinner message="Please wait..." />
  {:else if state === "waiting-payment"}
    <p>You will receive the avatar directly in your wallet.</p>
    <button on:click={() => handlePayment()}>Pay 1 ICP and Mint</button>
    <button on:click={() => handlePreorder()}>Preorder member ?</button>
  {:else if state === "waiting-payment-processing"}
    <Spinner message="Processing payment..." />
  {:else if state === "waiting-mint"}
    <Spinner message="Minting avatar..." />
  {:else if state === "avatar-minted"}
    <p>Congralutation : your avatar has been successfully minted 🚀</p>
    <a
      href="https://twitter.com/intent/tweet?text=I%27ve%20just%20minted%20my%20ICPSquad%20avatar%20!%20Join%20the%20squad%2C%20explore%20the%20ecosystem%2C%20have%20fun%20and%20earn%20prizes%20%3A%20icpsquad.dfinitycommunity.com%20.%20Powered%20by%20%23ICP"
      target="_blank"
      ><button> Share </button>
      <button on:click={() => handleDownload()}> Download </button>
    </a>
  {:else if state === "error"}
    <p>An errorr occured 😵‍💫</p>
    <p>{error_message}</p>
    <a href="https://discord.gg/CZ9JgnaySu" target="_blank"
      ><button> Support </button>
    </a>
    <Link to="/">
      <button>Home</button>
    </Link>
  {/if}
</div>

<style lang="scss">
  @use "./src/website/src/styles" as *;

  .checkout {
    grid-column: span 2;
  }

  button {
    max-width: 500px;
    margin-top: 20px;
  }

  .back {
    margin-top: 80px;
    color: $lightgrey;
    cursor: pointer;
  }
</style>
