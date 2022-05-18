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
  import type { AvatarComponents } from "@src/types/avatar.d";
  import type { AvatarColors } from "@src/types/color.d";

  export let state: State;
  export let setState: (newState: State) => void;

  export let colors : AvatarColors | undefined;
  export let components : AvatarComponents | undefined;

  let invoice: Invoice | undefined = undefined;
  let error_message : string | undefined;
  let token_identifier : string | undefined;

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
    setState("waiting-payment")
  }

  const handlePayment = async () => {
    setState("waiting-payment-processing");
    if(!invoice) {
      throw new Error("Invoice is not defined");
    } 
    const {wallet : Wallet} = get(user);
    console.log("wallet", Wallet);
    if(!Wallet) {
      throw new Error("Wallet is not defined");
    }
    const result = await payInvoice(invoice, Wallet);
    if(result.height > 0) {
      setState("waiting-mint");
    } else {
      setState("error")
      error_message = "Payment failed";
    }
  };

  const handlePreorder = () => {
    if(confirm("If you joined the preorder list but never minted your avatar, you can skip payment. This won't work otherwise. Were you part of the preorder?")) {
      setState("waiting-mint");
    };
  }

  $: if (state === "waiting-mint") {
    handleMint();
  }

  const handleMint = async () => {
    const result = await mintRequest(
      components,
      colors,
      invoice ? Number(invoice.id) : undefined
    );
    if("ok" in result) {
      token_identifier = result.ok; 
      setState("avatar-minted");
    } else {
      setState("error");
      error_message = result.err;
    }
  }
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
    <p>Congratulation : Your avatar has been minted 🎉 </p>
    <p> Your token identifier : { token_identifier } </p>
    <button> Share 🚀</button>
  {:else if state === "error"}
    <p>An errorr occured 😵‍💫</p>
    <p>{ error_message }</p>
    <button> Contact our support</button>
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
