<template>
  <div class="fixed top-0 bottom-0 left-0 right-0 flex flex-col items-center justify-center bg-opacity-30 bg-black">
    <div class="modal bg-white shadow-xl rounded-xl flex flex-col">
      <header class="border-gray-600 border-b-4 flex flex-row text-5xl font-bold text-gray-800 items-center pl-8 justify-between">
        <h3 class="text-center text-2xl font-bold text-gray-800">{{ name }}</h3>
        <button @click="close" class="bg-pink-600 p-2 m-2 rounded-xl">X</button>
      </header>
      <section class="flex flex-row items-center w-full justify-around mb-8">
        <!-- Description -->
        <div class="w-1/2 text-gray-800 text-center p-4 text-xl">
          <p class="text-xl font-bold text-gray-800">{{ description }}</p>
        </div>
        <!-- Recipe -->
        <recipe :recipe="recipe"></recipe>
      </section>
    </div>
  </div>
</template>
<script lang="ts">
import { defineComponent } from "vue";
import Recipe from "./Lab/Recipe.vue";

export default defineComponent({
  emits: ["close"],
  props: {
    name: {
      type: String,
      required: true,
    },
    description: {
      type: String,
      required: true,
    },
    recipe: {
      type: Array,
      required: true,
    },
  },
  setup(props, context) {
    const close = () => {
      context.emit("close");
    };

    return {
      close,
    };
  },
  components: {
    Recipe,
  },
});
</script>
