<script lang="ts">
  import Carat from "@icons/Carat.svelte";
  import Shuffle from "@icons/Shuffle.svelte";
  import AvatarComponentsSvg from "@components/AvatarComponentsSvg.svelte";
  import Header from "@components/Header.svelte";
  import Footer from "@components/Footer.svelte";
  import RenderAvatar from "@components/render/RenderAvatar.svelte";
  import RenderComponent from "@components/render/RenderComponent.svelte";
  import ColorPicker from "@components/ColorPicker.svelte";
  import type { AvatarColors } from "../types/color.d";
  import type { AvatarComponents } from "../types/avatar.d";
  import { generateRandomAvatar } from "@tasks/generate-avatar";
  import { generateRandomColor } from "@utils/color";
  import { backgrounds, profiles, ears, mouths, eyes, noses, hairs, clothes } from "@utils/list";

  import { faceAccessories, hatAccessories, eyesAccessories, bodyAccessories, miscAccessories } from "@utils/list";

  // Section 1 : Without accessories (for mainnet)
  /*   const categories = ["background", "profile", "ears", "mouth", "eyes", "nose", "hairs", "clothes"];
  const categoryToItems = {
    background: backgrounds,
    ears: ears,
    profile: profiles,
    hairs: hairs,
    eyes: eyes,
    nose: noses,
    mouth: mouths,
    clothes: clothes,
  }; */

  // Section 2 : With accessories (for testing)
  // IF YOU WANT TO USE THIS : Commnent out section 1 and uncomment section 2

  const categories = ["background", "profile", "ears", "mouth", "eyes", "nose", "hairs", "clothes", "hat", "face", "glasses", "body", "misc"];
  const categoryToItems = {
    background: backgrounds,
    ears: ears,
    profile: profiles,
    hairs: hairs,
    eyes: eyes,
    nose: noses,
    mouth: mouths,
    clothes: clothes,
    hat: hatAccessories,
    face: faceAccessories,
    glasses: eyesAccessories,
    body: bodyAccessories,
    misc: miscAccessories,
  };

  let categoryShowing = "eyes";
  let items = [];
  $: items = categoryToItems[categoryShowing];

  // Color management
  let colorPickers = [];
  $: if (categoryShowing && categoryToItems[categoryShowing]) {
    let newItems = [...categoryToItems[categoryShowing]];
    items = categoryShowing == "background" ? [] : [...newItems];
    colorPickers = categoryToColorPickers[categoryShowing] ? categoryToColorPickers[categoryShowing] : [];
    console.log("picker", colorPickers);
  }
  const categoryToColorPickers = {
    background: ["background"],
    profile: ["skin"],
    hairs: ["hairs", "eyebrows"],
    eyes: ["eyes", "eyeliner"],
    clothes: ["clothes"],
  };

  // Avatar management
  let components: AvatarComponents = generateRandomAvatar(0);
  const updateAvatarComponent = (category: string, item: string) => {
    console.log("update", category, item);
    components[category] = item;
  };

  let colors: AvatarColors = generateRandomColor();
  const updateAvatarColor = (name: string, color: any) => {
    colors[name] = [color.r, color.g, color.b, 1];
  };

  let randomlyResetAvatar = () => {
    components = generateRandomAvatar(0);
    colors = generateRandomColor();
  };
</script>

<Header />
<div class="page-header">
  <h1>Create Avatar</h1>
</div>
<main class="container">
  <div class="layout-grid">
    <div class="categories">
      {#each categories as category}
        <button on:click={() => (categoryShowing = category)} class="category {categoryShowing == category ? 'selected' : ''}">
          <div class="left">
            {category}
          </div>
          <Carat color={categoryShowing == category ? "#40b1f5" : "#E5E5E5"} />
        </button>
      {/each}
    </div>
    <div class="items">
      {#each colorPickers as componentName}
        <ColorPicker {updateAvatarColor} {componentName} selectedColorRGB={colors[componentName]} />
      {/each}
      {#each items as item}
        <div on:click={() => updateAvatarComponent(categoryShowing, item.name)} class="item {item == components[categoryShowing] ? 'selected' : ''}">
          <RenderComponent name={item.name} layers={item.layers} />
        </div>
      {/each}
    </div>
    <div class="avatar">
      <RenderAvatar avatarComponents={components} avatarColors={colors} />
      <button class="secondary shuffle" on:click={randomlyResetAvatar}>
        <div class="shuffle-icon">
          <Shuffle />
        </div>
        Random Reset
      </button>
    </div>
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

  input[type="color"] {
    background-color: transparent;
    border: 0;
    width: 40px;
    height: 40px;
    cursor: pointer;
    margin-right: 10px;
  }

  .layout-grid {
    display: grid;
    grid-template-columns: 1fr 1fr 1fr;
    grid-gap: 40px;
  }

  .color-picker {
    grid-column: span 3;
    display: flex;
    align-items: center;
  }

  .items {
    display: grid;
    grid-template-columns: 1fr 1fr 1fr;
    grid-gap: 20px;
  }

  .item {
    background-color: $darkgrey;
    border-radius: 10px;
    max-height: 125px;
    overflow: hidden;
    border: 3px solid transparent;
    &.selected {
      border-color: $green;
    }
  }

  #avatar-components {
    width: 0;
    height: 0;
  }

  button.category {
    background-color: $verydarkgrey;
    display: flex;
    justify-content: space-between;
    padding: 12px 40px;
    border-radius: 0;
    margin-bottom: 1px;
    &.selected {
      background-color: $darkgrey;
      color: $blue;
    }
  }
  button.shuffle {
    margin-top: 20px;
    line-height: 90%;
    .shuffle-icon {
      margin-right: 20px;
      padding-top: 2px;
    }
  }
</style>
