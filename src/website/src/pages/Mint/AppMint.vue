<template>
  <div class="flex flex-col h-full">
    <connexion-mint v-show="!connected" class="flex-1"></connexion-mint>
    <div
      class="flex lg:flex-row flex-col gap-y-6 lg:gap-y-0 h-full"
      v-show="connected"
    >
      <div class="flex flex-col lg:w-1/2 items-center mx-auto">
        <h2
          class="
            text-4xl
            font-bold
            text-gray-800 text-center
            mt-8
            lg:mt-14
            2xl:mt-20
          "
        >
          Your avatar 👨
        </h2>
        <div
          ref="avatar"
          class="
            md:w-96
            w-60
            h-auto
            border-4 border-pink-300
            bg-white
            mt-8
            lg:mt-14
            2xl:mt-20
          "
        ></div>
      </div>

      <div
        class="
          flex flex-col
          items-center
          lg:w-1/2 lg:border-l-2 lg:border-gray-400
          mx-auto
          min-h-screen
        "
      >
        <div>
          <h2
            class="
              text-4xl
              font-bold
              text-gray-800 text-center
              mt-8
              lg:mt-14
              2xl:mt-20
            "
          >
            {{ layers[layer].title }}
          </h2>
        </div>
        <div
          v-if="!minting"
          class="
            flex flex-row
            md:justify-around
            w-1/2
            justify-between
            mt-8
            lg:mt-14
            2xl:mt-20
          "
        >
          <div
            class="
              text-base
              md:text-2xl
              shadow-2xl
              text-white
              rounded
              py-3
              px-4
              md:px-8
              mt-8
              lg:mt-14
              2xl:mt-20
            "
            :class="[
              layers[layer].title === 'Background 🌈'
                ? 'bg-pink-300'
                : 'bg-pink-600 cursor-pointer transform hover:scale-95',
            ]"
            @click="previousLayer()"
          >
            Back
          </div>
          <div
            class="
              text-base
              md:text-2xl
              shadow-2xl
              text-white
              rounded
              py-3
              px-4
              md:px-8
              mt-8
              lg:mt-14
              2xl:mt-20
            "
            :class="[
              layers[layer].title === 'Mint ⛏'
                ? 'bg-pink-300'
                : 'bg-pink-600 cursor-pointer transform hover:scale-95',
            ]"
            @click="nextLayer"
          >
            Next
          </div>
        </div>

        <div v-if="layers[layer].title != 'Mint ⛏'">
          <h2
            class="
              text-center text-base text-gray-800
              font-bold
              md:text-2xl
              rounded
              py-3
              px-4
              md:px-8
              mt-8
              lg:mt-14
              2xl:mt-20
            "
          >
            Select an element to make your choice !
          </h2>
          <list
            v-if="layers[layer].title !== 'Background 🌈'"
            class="mx-auto"
            :components="layers[layer].components"
            :title="layers[layer].title"
            @click="draw"
          ></list>
          <div
            v-if="layers[layer].title === 'Eyes 👀'"
            class="flex md:flex-row flex-col justify-around py-8"
          >
            <div class="flex flex-col justify-center md:mx-12">
              <h2
                class="
                  text-gray-800
                  font-bold
                  text-center text-base
                  md:text-2xl md:px-8 md:mt-12
                  mt-8
                  lg:mt-14
                  2xl:mt-20
                "
              >
                Eye
              </h2>
              <color-picker
                class="mx-auto"
                :color_list="titleToListColors(layers[layer].title)"
                :title="layers[layer].title"
              ></color-picker>
            </div>

            <div class="flex flex-col justify-center md:mx-12">
              <h2
                class="
                  text-gray-800
                  font-bold
                  text-center text-base
                  md:text-2xl md:px-8 md:mt-12
                  mt-8
                  lg:mt-14
                  2xl:mt-20
                "
              >
                Eyebrows
              </h2>
              <color-picker
                class="mx-auto"
                :color_list="titleToListColors('Eyebrows')"
                :title="'Eyebrows'"
              ></color-picker>
            </div>
          </div>
          <color-picker
            class="mx-auto"
            v-if="checkTitle(layers[layer].title)"
            :color_list="titleToListColors(layers[layer].title)"
            :title="layers[layer].title"
          ></color-picker>
          <opacity-selector
            class="w-1/2"
            v-if="checkTitleOpacity(layers[layer].title)"
          ></opacity-selector>
        </div>
        <div v-else>
          <button-mint @mint="minting = true"></button-mint>
        </div>
      </div>
    </div>
  </div>
</template>

<script lang="ts">
import { defineComponent, onMounted, ref, computed, watch } from "vue";
import { frontend_layers } from "../../utils/list";
import buttonMint from "./AppMintButton.vue";
import List from "./AppMintList.vue";
import { renderAvatar } from "../../utils/render";
//@ts-ignore
import { useStore } from "vuex";
import {
  color_picker_layers,
  opacity_selector_layers,
  colors_background,
  colors_skin,
  colors_eyes,
  colors_hair,
  colors_clothes,
} from "../../utils/list";
import OpacitySelector from "../../components/OpacitySelector.vue";
import ColorPicker from "../../components/AppMintColorPicker.vue";
import ConnexionMint from "./AppHomeMinter.vue";

export default defineComponent({
  setup() {
    const layer = ref(0);
    const layers = frontend_layers;
    const minting = ref(false);

    const connected = computed(() => store.getters.isPrincipalSet);

    const avatar = ref(null);
    const nextLayer = () => {
      if (layer.value === layers.length - 1) {
        return;
      }
      layer.value = layer.value + 1;
      return;
    };

    const previousLayer = () => {
      if (layer.value === 0) {
        return;
      }
      layer.value = layer.value - 1;
      return;
    };
    const store = useStore();

    const draw = () => {
      //@ts-ignore
      renderAvatar(avatar.value, store.state.avatar);
    };

    const checkTitle = (title: string) => {
      if (title === "Eyes 👀") {
        return false; // Special case
      }
      return color_picker_layers.includes(title);
    };

    const checkTitleOpacity = (title: string) => {
      return opacity_selector_layers.includes(title);
    };

    watch(connected, (value) => {
      if (connected) {
        draw();
      }
    });

    const titleToListColors = (title: string) => {
      switch (title) {
        case "Background 🌈":
          return colors_background;
        case "Profile 👤":
          return colors_skin;
        case "Clothes 👔":
          return colors_clothes;
        case "Eyes 👀":
          return colors_eyes;
        case "Hairs 💇":
          return colors_hair;
        case "Eyebrows":
          return colors_hair;
        default:
          return [];
      }
    };

    onMounted(() => {
      if (store.getters.isPrincipalSet) {
        draw();
      }
    });

    return {
      nextLayer,
      previousLayer,
      draw,
      layer,
      layers,
      avatar,
      checkTitle,
      titleToListColors,
      checkTitleOpacity,
      minting,
      connected,
    };
  },
  components: {
    List,
    buttonMint,
    ColorPicker,
    OpacitySelector,
    ConnexionMint,
  },
});
</script>
