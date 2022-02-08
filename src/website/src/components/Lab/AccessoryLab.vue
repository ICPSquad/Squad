<template>
  <div class="flex flex-col items-center">
    <!-- Card -->
    <div><img :src="`cards/accessories/${name}.svg`" alt="Card_image" class="w-72" /></div>
    <!--  Button -->
    <div class="flex flex-row items-center gap-x-6">
      <button @click="showInfo" class="md:text-2xl text-xl shadow-xl text-white bg-pink rounded py-4 px-4 mt-6 cursor-pointer mx-auto mb-8">Recipe 🧪</button>
      <button @click="mint" class="md:text-2xl text-xl shadow-xl text-white bg-pink rounded py-4 px-4 mt-6 cursor-pointer mx-auto mb-8">Create ⛏</button>
    </div>
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
