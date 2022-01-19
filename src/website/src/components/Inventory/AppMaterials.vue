<template>
  <div class="w-full grid grid-cols-2 grid-rows-3 px-8 gap-x-5 gap-y-4 mb-4">
    <div class="md:w-44 w-32 mx-auto">
      <h2 class="text-white text-center mb-2 font-marker text-5xl">
        {{ object_inventory.Cloth }}
      </h2>
      <img src="cards/materials/Cloth.svg" alt="Cloth" />
    </div>
    <div class="md:w-44 w-32 mx-auto">
      <h2 class="text-white text-center mb-2 font-marker text-5xl">
        {{ object_inventory.Wood }}
      </h2>
      <img src="cards/materials/Wood.svg" alt="Wood" />
    </div>
    <div class="md:w-44 w-32 mx-auto">
      <h2 class="text-white text-center mb-2 font-marker text-5xl">
        {{ object_inventory.Metal }}
      </h2>
      <img src="cards/materials/Metal.svg" alt="Metal" />
    </div>
    <div class="md:w-44 w-32 mx-auto">
      <h2 class="text-white text-center mb-2 font-marker text-5xl">
        {{ object_inventory.Glass }}
      </h2>
      <img src="cards/materials/Glass.svg" alt="Glass" />
    </div>
    <div class="md:w-44 w-32 mx-auto">
      <h2 class="text-white text-center mb-2 font-marker text-5xl">
        {{ object_inventory.Circuit }}
      </h2>
      <img src="cards/materials/Circuit.svg" alt="Circuit" />
    </div>
    <div class="md:w-44 w-32 mx-auto">
      <h2 class="text-white text-center mb-2 font-marker text-5xl">
        {{ object_inventory.Stone }}
      </h2>
      <img src="cards/materials/Dfinity-stone.svg" alt="Dfinity-stone" />
    </div>
  </div>
</template>

<script lang="ts">
import { defineComponent } from "vue";
export default defineComponent({
  props: {
    object_inventory: {
      type: Object,
      required: true,
    },
  },
  setup(props) {
    return {
      object_inventory: props.object_inventory,
    };
  },
});
</script>
