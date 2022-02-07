<template>
  <div class="flex flex-grid md:grid-cols-4 grid-cols-1 items-center w-full gap-x-6 mt-8">
    <!-- Name -->
    <h3 class="text-center text-gray-800 font-marker font-bold lg:text-5xl md:text-2xl rounded py-3 px-4 md:px-8 mt-8 w-1/3">
      {{ name }}
    </h3>
    <!-- Card -->
    <div><img :src="`cards/accessories/${name}.svg`" alt="Card_image" class="w-72" /></div>
    <!-- <div>
      <p>{{ description }}</p>
    </div> -->
    <!-- Recipe -->
    <div class="w-64">
      <recipe :recipe="recipe"></recipe>
    </div>
    <!--  Button -->
    <button @click="mint" class=""></button>
  </div>
</template>

<script lang="ts">
import { defineComponent } from "vue";
import Recipe from "./Recipe.vue";

export default defineComponent({
  props: {
    name: {
      type: String,
      required: true,
    },
    recipe: {
      type: Array,
      required: true,
    },
    description: {
      type: String,
      required: true,
    },
  },
  emits: ["mint"],
  setup(props, { emit }) {
    const mint = () => {
      emit("mint", props.name);
    };
    return {
      mint,
    };
  },
  components: {
    Recipe,
  },
});
</script>
