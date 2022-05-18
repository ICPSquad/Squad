<script lang="ts">
  import Carat from "../../icons/Carat.svelte";
  import { suggestedColors, colorCategoryDisplayName } from "@utils/list";
  import { rgbToHex, hexToRgb } from "@utils/color";

  export let updateAvatarColor;
  export let componentName;
  export let selectedColorRGB;
  let showDetails = false;
  let selectedColorHex;
  $: selectedColorHex = rgbToHex(
    selectedColorRGB[0],
    selectedColorRGB[1],
    selectedColorRGB[2]
  );

  const handleColorChange = (event) => {
    const col = hexToRgb(event.target.value);
    updateAvatarColor(componentName, col);
  };
</script>

<div class="color-picker">
  <div class="preview" on:click={() => (showDetails = !showDetails)}>
    <div class="left">
      <div
        style="background-color: {selectedColorHex}"
        class="currentColorSquare"
      />
      {componentName ? colorCategoryDisplayName[componentName] : ""}
    </div>
    <Carat rotate={90} height={16} />
  </div>
  <div class="details {showDetails ? 'showing' : ''}">
    <div class="label">Suggested colors</div>
    {#each suggestedColors[componentName] as c}
      <div
        class="suggested-color"
        style="background-color: rgb({c[0] + ',' + c[1] + ',' + c[2]})"
        on:click={() =>
          updateAvatarColor(componentName, { r: c[0], g: c[1], b: c[2] })}
      />
    {/each}
    <label>
      <input
        on:input={handleColorChange}
        name={componentName}
        type="color"
        value={selectedColorHex}
      />
      <span>🎨</span> More colors
    </label>
  </div>
</div>

<style lang="scss">
  @use "../../styles" as *;

  .currentColorSquare,
  .suggested-color {
    width: 30px;
    height: 30px;
    border-radius: 6px;
    margin-right: 10px;
  }
  label {
    display: flex;
    flex-direction: row;
    justify-content: center;
    align-items: center;
    background-color: transparent;
    border: 1px solid $midgrey;
    border-radius: 12px;
    width: 100%;
    text-transform: uppercase;
    color: $midgrey;
    font-weight: bold;
    margin-top: 30px;
    padding: 4px;
    font-size: 0.8rem;
    cursor: pointer;
    &:hover {
      color: $white;
      border-color: $white;
    }
    span {
      font-size: 1.4rem;
      margin-right: 10px;
    }
  }
  input[type="color"] {
    display: inline-block;
    height: 0;
    width: 0;
    border: none;
    outline: none;
    opacity: 0;
  }
  .color-picker {
    grid-column: span 3;
    border: 1px solid $darkgrey;
    border-radius: 10px;
    padding: 20px;
  }
  .preview {
    width: 100%;
    display: flex;
    align-items: center;
    text-transform: uppercase;
    justify-content: space-between;
    cursor: pointer;
    .left {
      display: flex;
      align-items: center;
    }
  }
  .details {
    display: none;
    padding-top: 40px;
    &.showing {
      display: block;
    }
  }
  .suggested-color {
    display: inline-block;
    margin-right: 10px;
    cursor: pointer;
  }
  .label {
    text-transform: uppercase;
    color: $midgrey;
    font-weight: bold;
    font-size: 0.8rem;
    margin-bottom: 10px;
  }

  @media (max-width: 960px) {
    .color-picker {
      padding: 10px 20px;
      grid-column: span 4;
    }
  }

  @media (max-width: 600px) {
    .color-picker {
      padding: 10px 20px;
      grid-column: span 3;
    }
  }
</style>
