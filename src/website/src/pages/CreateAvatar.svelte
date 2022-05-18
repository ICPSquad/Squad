<script lang="ts">
  import AvatarComponentsSvg from "@components/AvatarComponentsSvg.svelte";
  import Header from "@src/components/shared/Header.svelte";
  import Footer from "@src/components/shared/Footer.svelte";
  import type { AvatarColors } from "../types/color.d";
  import type { AvatarComponents } from "../types/avatar.d";
  import { generateRandomAvatar, filterOption } from "@tasks/generate-avatar";
  import { generateRandomColor } from "@utils/color";
  import type { Invoice__1 as Invoice } from "@canisters/invoice/invoice.did.d";
  import { user } from "../store/user";
  import { get } from "svelte/store";
  import { mintRequest } from "@utils/mint";
  import { createInvoice } from "@utils/invoice";
  import { payInvoice } from "@utils/payment";
  import Categories from "@src/components/create-avatar/Categories.svelte";
  import ItemSelection from "@src/components/create-avatar/ItemSelection.svelte";
  import AvatarPreview from "@src/components/create-avatar/AvatarPreview.svelte";

  // Include accessories?
  let includeAccessories = false;

  // Category showing
  let categoryShowing = "profile";
  const setCategoryShowing = (category) => {
    categoryShowing = category;
  };

  // Color management
  let colors: AvatarColors = generateRandomColor();
  const updateAvatarColor = (name: string, color: any) => {
    colors[name] = [color.r, color.g, color.b, 1];
  };

  // Avatar management
  let components: AvatarComponents = generateRandomAvatar(
    0,
    Math.random() > 0.5 ? filterOption.Man : filterOption.Woman
  );
  const updateAvatarComponent = (category: string, item: string) => {
    console.log("update", category, item);
    components[category] = item;
  };

  // Random reset function
  let randomlyResetAvatar = () => {
    components = generateRandomAvatar(
      0,
      Math.random() > 0.5 ? filterOption.Man : filterOption.Woman
    );
    colors = generateRandomColor();
  };

  // Interractions with canister. Not sure how to manage the followings : UI/Error handling... ?
  let state:
    | "idle"
    | "waiting-invoice"
    | "waiting-payment"
    | "waiting-mint"
    | "done" = "idle";
  let invoice: Invoice | undefined = undefined;

  async function handleSubmit() {
    if (state == "waiting-invoice" || state == "waiting-mint") {
      return;
    }
    if (state == "waiting-payment") {
      const result = await mintRequest(
        components,
        colors,
        Number(invoice.id) as number
      );
      console.log("mint result", result);
    }
    invoice = await createInvoice("AvatarMint");
    console.log("invoice", invoice);
    state = "waiting-payment";
  }
</script>

<Header />
<div class="page-header">
  <h1>Create Avatar</h1>
</div>
<main class="container">
  <div class="layout-grid">
    <Categories {includeAccessories} {categoryShowing} {setCategoryShowing} />
    <ItemSelection
      {colors}
      {updateAvatarColor}
      {updateAvatarComponent}
      {categoryShowing}
      {components}
    />
    <AvatarPreview {components} {randomlyResetAvatar} {colors} {handleSubmit} />
  </div>
</main>
<Footer />
<div id="avatar-components">
  <AvatarComponentsSvg />
</div>

<style lang="scss">
  @use "./src/website/src/styles" as *;

  main {
    --page-feature-color: #{$pink};
  }
  .layout-grid {
    display: grid;
    grid-template-columns: 1fr 1fr 1fr;
    grid-gap: 40px;
  }
  #avatar-components {
    width: 0;
    height: 0;
  }
  button.mint {
    margin-top: 20px;
  }
  p.small {
    font-size: 0.9rem;
    text-align: center;
    margin-top: 10px;
  }

  .avatar {
    position: relative;
  }
  button.shuffle {
    position: absolute;
    --size: 54px;
    width: var(--size);
    height: var(--size);
    padding: 0;
    border-radius: 50%;
    background-color: $black;
    border: 2px solid $green;
    right: 10px;
    top: 10px;
    .shuffle-icon {
      padding-top: 4px;
    }
  }
</style>
