<template>
  <div class="mx-auto recipe-border">
    <div class="flex flex-col recipe text-white">
      <div>
        <h3 class="text-center text-2xl font-bold my-4">Ingredients 🧪</h3>
      </div>
      <div class="flex flex-row w-full">
        <div class="flex flex-col w-1/2">
          <div class="flex flex-row items-center">
            <img src="others/material/Cloth.svg" alt="Cloth-card" class="w-1/2 h-auto" />
            <h3 class="text-xl font-marker">{{ numberCloth }}</h3>
          </div>
          <!-- Wood -->
          <div class="flex flex-row items-center">
            <img src="others/material/Wood.svg" alt="Wood-card" class="w-1/2 h-auto" />
            <h3 class="text-xl font-marker">{{ numberWood }}</h3>
          </div>
          <!-- Glass -->
          <div class="flex flex-row items-center">
            <img src="others/material/Glass.svg" alt="Glass-card" class="w-1/2 h-auto" />
            <h3 class="text-xl font-marker">{{ numberGlass }}</h3>
          </div>
        </div>
        <div class="flex flex-col w-1/2">
          <!-- Metal -->
          <div class="flex flex-row items-center">
            <img src="others/material/Metal.svg" alt="Metal-card" class="w-1/2 h-auto" />
            <h3 class="text-xl font-marker">{{ numberMetal }}</h3>
          </div>
          <!-- Circuit -->
          <div class="flex flex-row items-center">
            <img src="others/material/Circuit.svg" alt="Circuit-card" class="w-1/2 h-auto" />
            <h3 class="text-xl font-marker">{{ numberCircuit }}</h3>
          </div>
          <!-- Dfinity-stone -->
          <div class="flex flex-row items-center">
            <img src="others/material/Dfinity-stone.svg" alt="Dfinity-stone-card" class="w-1/2 h-auto" />
            <h3 class="text-xl font-marker">{{ numberDfinityStone }}</h3>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script lang="ts">
import { defineComponent, ref } from "vue";

export default defineComponent({
  props: {
    // A recipe is a list of materials as string : ["Wood", "Cloth", "Cloth", "Glass"]
    recipe: {
      type: Array,
      required: true,
    },
  },
  setup(props, { attrs }) {
    const numberCloth = ref<number>(0);
    const numberWood = ref<number>(0);
    const numberGlass = ref<number>(0);
    const numberMetal = ref<number>(0);
    const numberCircuit = ref<number>(0);
    const numberDfinityStone = ref<number>(0);

    //Convert recipe to fill all numbers
    for (const material of props.recipe) {
      switch (material) {
        case "Cloth":
          numberCloth.value++;
          break;
        case "Wood":
          numberWood.value++;
          break;
        case "Glass":
          numberGlass.value++;
          break;
        case "Metal":
          numberMetal.value++;
          break;
        case "Circuit":
          numberCircuit.value++;
          break;
        case "Dfinity-stone":
          numberDfinityStone.value++;
          break;
        default:
          //TODO : Treat special materials like "Cronics-essence"
          break;
      }
    }

    return {
      numberCloth,
      numberWood,
      numberGlass,
      numberMetal,
      numberCircuit,
      numberDfinityStone,
    };
  },
});
</script>
<style scoped>
.recipe-border {
  border-image: linear-gradient(90deg, rgb(87, 39, 133) 0%, rgb(237, 30, 121) 25%, rgb(41, 171, 226) 51%, rgb(241, 90, 36) 76%, rgb(251, 176, 59) 100%);
  border-width: 10px;
  border-image-slice: 1;
  width: 32rem;
}
.recipe {
  background: linear-gradient(90deg, rgb(7, 30, 41) 0%, rgb(99, 40, 118) 100%);
}
</style>
