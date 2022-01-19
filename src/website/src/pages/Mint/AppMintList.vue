<template>
  <div>
    <div
      class="
        flex flex-row flex-wrap
        items-center
        gap-6
        justify-center
        mt-8
        px-6
      "
    >
      <li
        v-for="component in components"
        :key="component.name"
        class="list-none w-44 cursor-pointer"
        @click="changeSelectedComponent(component)"
      >
        <div
          :class="[
            selected === component.name
              ? 'border-4 border-pink-400'
              : 'border-4 border-gray-400',
          ]"
        >
          <svg class="h-auto w-full">
            <use :href="getPreview(component.name)"></use>
          </svg>
        </div>
      </li>
    </div>
    <div
      v-if="
        (selected === 'Miss-annoyed-eyes' && title === 'Eyes 👀') ||
        (selected === 'Miss-confident-eyes' && title === 'Eyes 👀') ||
        (selected === 'Miss-disgusted-eyes' && title === 'Eyes 👀') ||
        (selected === 'Miss-scheming-eyes' && title === 'Eyes 👀') ||
        (selected === 'Miss-surprised-eyes' && title === 'Eyes 👀')
      "
    >
      <h2
        class="
          text-gray-800
          font-bold
          text-center text-base
          md:text-2xl md:px-8 md:mt-12
          mt-6
        "
      >
        Eyeliner 💅
      </h2>
      <color-picker :color_list="colors_eyeliner" title="Eyeliner">
      </color-picker>
    </div>
  </div>
</template>

<script lang="ts">
import { defineComponent, ref } from "vue";
import { fromPropsTitleToRightAction } from "./MintUtils";
import ColorPicker from "../../components/AppMintColorPicker.vue";
import { colors_eyeliner } from "../../../src/utils/list";
export default defineComponent({
  props: ["components", "title"],
  setup(props, context) {
    const selected = ref<string>("");

    const changeSelectedComponent = (c: any) => {
      selected.value = c.name;
      fromPropsTitleToRightAction(props.title, c);
      return;
    };

    const getPreview = (name: string) => {
      if (name === "Hair-13") {
        return "#" + name + "-full"; // Crappy way to deal with this haircut that has different layers associated with it
      }
      return "#" + name;
    };

    return {
      selected,
      changeSelectedComponent,
      colors_eyeliner,
      getPreview,
    };
  },
  components: {
    ColorPicker,
  },
});
</script>
