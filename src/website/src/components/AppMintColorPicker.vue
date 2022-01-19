<template>
  <div v-if="!isHairSpecial">
    <div
      class="
        flex flex-row flex-wrap
        md:mt-12
        mt-6
        gap-6
        mx-auto
        px-12
        justify-center
      "
    >
      <li
        v-for="color in color_list"
        :key="color"
        @click="changeColor(color)"
        class="list-none lg:w-20 lg:h-20 h-12 w-12 rounded-full cursor-pointer"
        :style="arrayToRGB(color)"
      ></li>
    </div>
    <div class="flex flex-col items-center justify-center md:mt-12 mt-6">
      <div class="relative">
        <button
          @click="openColorPicker"
          class="
            md:text-2xl
            text-xl
            shadow-xl
            text-white
            bg-pink
            rounded
            py-4
            px-4
            mt-6
            cursor-pointer
            mx-auto
            mb-8
          "
        >
          Custom 🎨
        </button>
        <input
          class="color-picker"
          type="color"
          ref="colorPicker"
          name="personalColor"
          @change="changeColorPicker()"
          :value="
            rgbToHex(colorSelected[0], colorSelected[1], colorSelected[2])
          "
        />
      </div>
    </div>
  </div>
  <div v-else>
    <h2
      class="
        text-center text-base text-gray-800
        font-bold
        md:text-2xl
        rounded
        py-3
        px-4
        md:px-8 md:mt-12
      "
    >
      The color can't be modified for this selection.
    </h2>
  </div>
</template>

<script lang="ts">
import { Color } from "declarations/nft/nft.did";
import { defineComponent, ref, computed } from "vue";
import { changeCSSVariable, changeColorInStore } from "../types/color";
import { useStore } from "vuex";

export default defineComponent({
  props: ["color_list", "title"],
  setup(props, { emit }) {
    const store = useStore();
    const arrayToRGB = (color: Color) => {
      return {
        backgroundColor: `rgb(${color[0]}, ${color[1]}, ${color[2]})`,
      };
    };

    const colorSelected = ref<Color>(props.color_list[0]);
    // Get the input element in the dom
    const colorPicker = ref(null);

    const changeColor = (color: Color) => {
      colorSelected.value = color;
      changeColorInStore(color, props.title);
      changeCSSVariable(color, props.title);
    };
    const openColorPicker = () => {
      //@ts-ignore
      // colorPicker.value.focus();
      // //@ts-ignore
      // colorPicker.value.value = "#FFCC00";
      //@ts-ignore
      colorPicker.value.click();
    };

    const changeColorPicker = () => {
      let color_object = hexToRgb(
        //@ts-ignore
        colorPicker.value.value
      );
      //@ts-ignore
      let color: Color = [color_object.r, color_object.g, color_object.b];
      colorSelected.value = color;
      changeColor(color);
    };

    // To convert rgb values in hexadecimal format to set up the color picker
    function componentToHex(c) {
      var hex = c.toString(16);
      return hex.length == 1 ? "0" + hex : hex;
    }

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

    const rgbToHex = (r, g, b) => {
      return "#" + componentToHex(r) + componentToHex(g) + componentToHex(b);
    };

    return {
      arrayToRGB,
      changeColor,
      changeColorPicker, // An updated version to use the color picker
      colorPicker,
      openColorPicker,
      colorSelected,
      rgbToHex,
      isHairSpecial: computed(() => store.getters.isSpecialHairs),
    };
  },
});
</script>

<style scoped>
#personalColor {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
}

.color-picker {
  position: absolute;
  z-index: -1;
  top: 25px;
  left: 25px;
  width: 1px;
}
</style>
