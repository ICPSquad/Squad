<script lang="ts">
  import type { Invoice__1 as Invoice } from "@canisters/invoice/invoice.did.d";
  import type { State } from "@src/components/create-avatar/types";
  import { user } from "@src/store/user";
  import { get } from "svelte/store";
  import { mintRequest } from "@utils/mint";
  import { createInvoice } from "@utils/invoice";
  import { payInvoice } from "@utils/payment";
  import Spinner from "./Spinner.svelte";

  export let state: State;
  export let setState: (newState: State) => void;

  let invoice: Invoice | undefined = undefined;

  // if (state == "waiting-invoice" || state == "waiting-mint") {
  //   return;
  // }
  // if (state == "waiting-payment") {
  //   const result = await mintRequest(
  //     components,
  //     colors,
  //     Number(invoice.id) as number
  //   );
  //   console.log("mint result", result);
  // }
  // invoice = await createInvoice("AvatarMint");
  // console.log("invoice", invoice);
  // state = "waiting-payment";

  const handleConnectPlug = () => {
    // TO DO

    // once connected
    setState("waiting-invoice");
  };

  const handleConnectStoic = () => {
    // TO DO

    // once connected
    setState("waiting-invoice");
  };

  $: if (state === "waiting-invoice") {
    // TO DO - Generate invoice

    // Simulate waiting for invoice
    setTimeout(() => {
      // once have invoice
      setState("waiting-payment");
    }, 4000);
  }

  const handlePayment = () => {
    setState("waiting-payment-processing");
    // TO DO - Process payment

    // Simulate processing payment
    setTimeout(() => {
      // once payment confirmed
      setState("waiting-mint");
    }, 4000);
  };

  $: if (state === "waiting-mint") {
    // TO DO - Mint avatar

    // Simulate waiting for mint
    setTimeout(() => {
      // once done
      setState("avatar-minted");
    }, 4000);
  }
</script>

<div class="checkout">
  <h3>Mint your avatar</h3>
  {#if state === "waiting-wallet-connection"}
    <p>Please connect a wallet to continue</p>
    <button on:click={() => handleConnectPlug()}>Connect Plug wallet</button>
    <button on:click={() => handleConnectStoic()}>Connect Stoic wallet</button>
    <div class="back" on:click={() => setState("creating-avatar")}>← Back</div>
  {:else if state === "waiting-invoice"}
    <Spinner message="Please wait..." />
  {:else if state === "waiting-payment"}
    <p>Minting your avatar costs 1 ICP</p>
    <button on:click={() => handlePayment()}>Pay 1 ICP and Mint</button>
  {:else if state === "waiting-payment-processing"}
    <Spinner message="Processing payment..." />
  {:else if state === "waiting-mint"}
    <Spinner message="Minting avatar..." />
  {:else if state === "avatar-minted"}
    <p>Your avatar is minted! 🎉</p>
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
