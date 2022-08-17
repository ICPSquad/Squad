<script lang="ts">
  import { Link } from "svelte-routing";
  import type { Invoice__1 as Invoice } from "@canisters/invoice/invoice.did.d";
  import Spinner from "../shared/Spinner.svelte";
  import ConnectButton from "../shared/ConnectButton.svelte";
  import type { State } from "@src/components/create-accessory/types";
  import { inventory, checkRecipe } from "@src/store/inventory";
  import { nameToRecipe } from "@src/utils/recipes";
  import { createInvoice } from "@utils/invoice";
  import { payInvoice } from "@utils/payment";
  import { user } from "@src/store/user";
  import { get } from "svelte/store";
  import { nameToSlot } from "@src/utils/list";

  import MissingMaterials from "./MissingMaterials.svelte";
  import { mintRequestAccessory, capitalizeFirstLetter } from "@src/utils/mint";

  export let state: State;
  export let setState: (newState: State) => void;
  export let cardSelected: string;

  // In case we encounter an error or the user has not enough materials.
  let error_message: string | undefined;
  let missing_materials: string[];
  let processing: boolean = false;

  let invoice: Invoice | undefined;
  let tokens_materials: string[];
  // The accessory is reading for minting when we have an invoice and when we have a verified recipe with the tokens.
  $: ready = invoice && tokens_materials;
  $: if (ready) {
    setState("waiting-payment");
  }
  $: if (state === "waiting-invoice") {
    handleInvoice();
  }

  $: if (state === "error") {
    processing = false;
  }

  const handleInvoice = async () => {
    invoice = await createInvoice("AccessoryFee");
  };

  user.subscribe(async (user) => {
    if (user.loggedIn) {
      setState("waiting-invoice");
    }
  });

  const handlePayment = async () => {
    if (processing) {
      return;
    }
    processing = true;
    setState("waiting-payment");
    if (!invoice) {
      processing = false;
      throw new Error("Invoice is not defined");
    }
    const { wallet: Wallet } = get(user);
    if (!Wallet) {
      processing = false;
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
    } catch (e) {
      alert(e);
      setState("error");
      error_message = "Payment was rejected.";
    }
  };

  $: if (state === "waiting-mint") {
    handleMint();
  }

  const handleMint = async () => {
    try {
      const result = await mintRequestAccessory(capitalizeFirstLetter(cardSelected), Number(invoice.id));
      if ("ok" in result) {
        setState("accessory-minted");
        processing = false;
      } else {
        setState("error");
        error_message = result.err;
      }
    } catch (e) {
      setState("error");
      error_message = "The minting operation was rejected by the wallet";
    }
  };

  const handleVerification = async () => {
    const result = await checkRecipe(nameToRecipe(cardSelected));
    if ("err" in result) {
      missing_materials = result.err;
      setState("missing-materials");
    }
    if ("ok" in result) {
      tokens_materials = result.ok;
    }
  };

  inventory.subscribe(async (inventory) => {
    if (inventory) {
      handleVerification();
    }
  });
</script>

<div class="checkout">
  <h3>Mint an accessory</h3>
  {#if state === "waiting-wallet-connection"}
    <p>Please connect a wallet to continue</p>
    <ConnectButton />
    <div class="back" on:click={() => setState("creating-accessory")}>← Back</div>
  {:else if state === "waiting-inventory" || state === "waiting-invoice"}
    <Spinner message={"Please wait..."} />
  {:else if state === "waiting-mint"}
    <Spinner message={"Creating your accessory..."} />
  {:else if state === "missing-materials"}
    <MissingMaterials {missing_materials} />
    <div class="back" on:click={() => setState("creating-accessory")}>← Back</div>
  {:else if state === "error"}
    <p>An error occured 😵‍💫</p>
    <p>{error_message}</p>
    <a href="https://discord.gg/CZ9JgnaySu" target="_blank"><button> Support </button> </a>
    <div class="back" on:click={() => setState("creating-accessory")}>← Back</div>
  {:else if state === "accessory-minted"}
    <p>Congratulation : your accessory has been successfully minted !</p>
    <p>You will receive it in your wallet in a few seconds 🎁</p>
    <Link to="/">
      <button>Home</button>
    </Link>
  {:else if ready}
    <p>You will receive the accessory directly in your wallet.</p>
    <img src="/assets/accessories/{nameToSlot(cardSelected)}/{cardSelected}/{cardSelected}-minified.svg" alt="Card" />
    <button on:click={() => handlePayment()}>Pay & mint</button>
  {/if}
</div>

<style lang="scss">
  @use "./src/website/src/styles" as *;

  .checkout {
    grid-column: span 2;
  }

  button {
    margin-top: 20px;
  }

  .back {
    margin-top: 80px;
    color: $lightgrey;
    cursor: pointer;
  }

  img {
    max-width: 250px;
    margin-top: 20px;
  }
</style>
