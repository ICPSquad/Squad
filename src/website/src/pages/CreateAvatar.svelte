<script>
  import Header from "../components/Header.svelte";
  import Footer from "../components/Footer.svelte";
  import { onMount } from "svelte";
  import { renderAvatar } from "../../src/utils/render";
  import AvatarComponentsSvg from "../components/AvatarComponentsSvg.svelte";
  import {
    backgrounds,
    ears,
    profiles,
    hairs,
    eyes,
    noses,
    mouths,
    clothes,
    accessories,
  } from "../../src/utils/list";
  import {
    categories,
    categoryToFolder,
    categoryDisplayName,
  } from "../../src/utils/categories";
  import Carat from "../icons/Carat.svelte";
  import ColorPicker from "../components/ColorPicker.svelte";
  import { suggestedColors } from "../types/color";
  import Shuffle from "../icons/Shuffle.svelte";

  const categoryToItems = {
    Background: backgrounds,
    Ears: ears,
    Profile: profiles,
    Hairs: hairs,
    Eyes: eyes,
    Nose: noses,
    Mouth: mouths,
    Clothes: clothes,
    Accessory: accessories,
  };

  const categoryToColorPickers = {
    Background: ["Background"],
    Profile: ["Skin"],
    Hairs: ["Hairs", "Eyebrows"],
    Eyes: ["Eyes", "Eyeliner"],
    Clothes: ["Clothes"],
  };

  let categoryShowing = "Profile";
  let items = [];
  let colorPickers = [];
  $: if (categoryShowing && categoryToItems[categoryShowing]) {
    let newItems = [...categoryToItems[categoryShowing]];
    items = categoryShowing == "Background" ? [] : [...newItems];
    colorPickers = categoryToColorPickers[categoryShowing]
      ? categoryToColorPickers[categoryShowing]
      : [];
  }

  const randomlySelect = (numOptions) => {
    return Math.floor(Math.random() * numOptions);
  };

  let avatar = {
    Background: backgrounds[0],
    Profile: profiles[randomlySelect(profiles.length)],
    Ears: ears[randomlySelect(ears.length)],
    Eyes: eyes[randomlySelect(eyes.length)],
    Nose: noses[randomlySelect(noses.length)],
    Mouth: mouths[randomlySelect(mouths.length)],
    Hairs: hairs[randomlySelect(hairs.length)],
    Clothes: clothes[randomlySelect(clothes.length)],
    // Accessory: accessories[1],
    Colors: {
      Skin: suggestedColors.Skin[randomlySelect(suggestedColors.Skin.length)],
      Hairs:
        suggestedColors.Hairs[randomlySelect(suggestedColors.Hairs.length)],
      Eyes: suggestedColors.Eyes[randomlySelect(suggestedColors.Eyes.length)],
      Eyebrows:
        suggestedColors.Eyebrows[
          randomlySelect(suggestedColors.Eyebrows.length)
        ],
      Background:
        suggestedColors.Background[
          randomlySelect(suggestedColors.Background.length)
        ],
      Eyeliner:
        suggestedColors.Eyeliner[
          randomlySelect(suggestedColors.Eyeliner.length)
        ],
      Clothes:
        suggestedColors.Clothes[randomlySelect(suggestedColors.Clothes.length)],
    },
  };

  const randomlyResetAvatar = () => {
    let avatarNew = {
      Background: backgrounds[0],
      Profile: profiles[randomlySelect(profiles.length)],
      Ears: ears[randomlySelect(ears.length)],
      Eyes: eyes[randomlySelect(eyes.length)],
      Nose: noses[randomlySelect(noses.length)],
      Mouth: mouths[randomlySelect(mouths.length)],
      Hairs: hairs[randomlySelect(hairs.length)],
      Clothes: clothes[randomlySelect(clothes.length)],
      // Accessory: accessories[1],
      Colors: {
        Skin: suggestedColors.Skin[randomlySelect(suggestedColors.Skin.length)],
        Hairs:
          suggestedColors.Hairs[randomlySelect(suggestedColors.Hairs.length)],
        Eyes: suggestedColors.Eyes[randomlySelect(suggestedColors.Eyes.length)],
        Eyebrows:
          suggestedColors.Eyebrows[
            randomlySelect(suggestedColors.Eyebrows.length)
          ],
        Background:
          suggestedColors.Background[
            randomlySelect(suggestedColors.Background.length)
          ],
        Eyeliner:
          suggestedColors.Eyeliner[
            randomlySelect(suggestedColors.Eyeliner.length)
          ],
        Clothes:
          suggestedColors.Clothes[
            randomlySelect(suggestedColors.Clothes.length)
          ],
      },
    };
    avatar = { ...avatarNew };
    const avatarDiv = document.getElementById("avatar");
    // @ts-ignore
    renderAvatar(avatarDiv, avatar);
  };

  const updateAvatarColor = (componentName, col) => {
    let avatarNew = { ...avatar };
    avatarNew.Colors[componentName] = [col.r, col.g, col.b, 1];
    avatar = { ...avatarNew };
    renderUpdatedAvatar(avatarNew);
  };

  const updateAvatar = (category, item) => {
    let avatarNew = { ...avatar };
    avatarNew[category] = item;
    avatar = { ...avatarNew };
    renderUpdatedAvatar(avatarNew);
  };

  const renderUpdatedAvatar = (avatar) => {
    const avatarDiv = document.getElementById("avatar");
    renderAvatar(avatarDiv, avatar);
  };

  onMount(() => {
    randomlyResetAvatar();
  });
</script>

<Header />
<div class="page-header">
  <h1>Create Avatar</h1>
</div>
<main class="container">
  <div class="layout-grid">
    <div class="categories">
      {#each categories as category}
        <button
          on:click={() => (categoryShowing = category)}
          class="category {categoryShowing == category ? 'selected' : ''}"
        >
          <div class="left">
            {categoryDisplayName[category]}
          </div>
          <Carat color={categoryShowing == category ? "#40b1f5" : "#E5E5E5"} />
        </button>
      {/each}
    </div>
    <div class="items">
      {#each colorPickers as componentName}
        <ColorPicker
          {updateAvatarColor}
          {componentName}
          selectedColorRGB={avatar.Colors[componentName]}
        />
      {/each}
      {#each items as item}
        <div
          on:click={() => updateAvatar(categoryShowing, item)}
          class="item {item == avatar[categoryShowing] ? 'selected' : ''}"
        >
          <img
            type="image/svg+xml"
            src="/assets/avatar-components/{categoryToFolder[
              categoryShowing
            ]}/{item.name}.svg"
            alt={item.name}
          />
        </div>
      {/each}
    </div>
    <div class="avatar">
      <div id="avatar" />
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
  @use "./src/styles" as *;

  main {
    --page-feature-color: #{$pink};
  }

  .layout-grid {
    display: grid;
    grid-template-columns: 1fr 1fr 1fr;
    grid-gap: 40px;
  }

  .items {
    display: grid;
    grid-template-columns: 1fr 1fr 1fr;
    grid-gap: 20px;
    grid-auto-rows: minmax(min-content, max-content);
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
