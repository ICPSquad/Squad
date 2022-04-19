<script>
  import Carat from "../icons/Carat.svelte";
  import { defaultColors } from "../types/color";

  export let updateAvatarColor;
  export let componentName;
  export let selectedColorRGB;

  let showDetails = true;

  let selectedColorHex;
  $: selectedColorHex = rgbToHex(
    selectedColorRGB[0],
    selectedColorRGB[1],
    selectedColorRGB[2]
  );

  function hexToRgb(hex) {
    var result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
    return result
      ? {
          r: parseInt(result[1], 16),
          g: parseInt(result[2], 16),
          b: parseInt(result[3], 16),
        }
      : null;
  }

  function rgbToHex(r, g, b) {
    console.log(r + "," + g + "," + b);
    return "#" + ((1 << 24) + (r << 16) + (g << 8) + b).toString(16).slice(1);
  }

  const handleColorChange = (event) => {
    const col = hexToRgb(event.target.value);
    updateAvatarColor(componentName, col);
  };

  // const handlePickSuggestColor =
</script>

<div class="color-picker">
  <div class="preview" on:click={() => (showDetails = !showDetails)}>
    <div class="left">
      <div
        style="background-color: {selectedColorHex}"
        class="currentColorSquare"
      />
      {componentName ? componentName : ""} COLOR
    </div>
    <Carat rotate={90} height={16} />
  </div>
  <div class="details {showDetails ? 'showing' : ''}">
    <div class="label">Suggested colors</div>
    {#each defaultColors[componentName] as c}
      <div
        class="suggested-color"
        style="background-color: rgb({c[0] + ',' + c[1] + ',' + c[2]})"
        on:click={() =>
          updateAvatarColor(componentName, { r: c[0], g: c[1], b: c[2] })}
      />
    {/each}
    <button> <span>🎨</span> More colors </button>
    <input
      on:change={handleColorChange}
      name={componentName}
      type="color"
      value={selectedColorHex}
    />
  </div>
</div>

<style lang="scss">
  @use "./src/styles" as *;

  .currentColorSquare,
  .suggested-color {
    width: 30px;
    height: 30px;
    border-radius: 6px;
    margin-right: 10px;
  }

  button {
    background-color: transparent;
    border: 1px solid $midgrey;
    text-transform: uppercase;
    color: $midgrey;
    font-weight: bold;
    font-size: 0.8rem;
    margin-top: 20px;
    padding: 4px;
    span {
      font-size: 1.4rem;
      margin-right: 10px;
    }
  }

  input[type="color"] {
    background-color: transparent;
    border: 0;
    width: 40px;
    height: 40px;
    cursor: pointer;
    margin-right: 10px;
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
</style>
