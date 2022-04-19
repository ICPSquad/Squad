<template>
  <div class="flex flex-col items-center">
    <!-- Card -->
    <div><img :src="`cards/accessories/${name}.svg`" alt="Card_image" class="w-72" /></div>
    <!--  Button -->
    <div class="flex flex-row items-center gap-x-6">
      <button @click="showModalRecipe" class="md:text-2xl text-xl shadow-xl text-white bg-pink rounded py-4 px-4 mt-6 cursor-pointer mx-auto mb-8">Recipe 🧪</button>
      <button @click="showModaltMint" class="md:text-2xl text-xl shadow-xl text-white bg-pink rounded py-4 px-4 mt-6 cursor-pointer mx-auto mb-8">Create ⛏</button>
    </div>
    <!-- Modal -->
    <modal-recipe :name="name" :description="description" :recipe="recipe" v-if="isVisibleModalRecipe" @close="closeModalRecipe"></modal-recipe>
    <modal-mint :name="name" :recipe="recipe" v-if="isVisibleModalMint" @close="closeModalMint"></modal-mint>
  </div>
</template>

<script lang="ts">
import { defineComponent, ref } from "vue";
import Recipe from "./Recipe.vue";
import ModalRecipe from "../ModalRecipe.vue";
import ModalMint from "../ModalMint.vue";

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
  setup(props, context) {
    const isVisibleModalRecipe = ref(false);
    const showModalRecipe = () => {
      isVisibleModalRecipe.value = true;
    };
    const closeModalRecipe = () => {
      isVisibleModalRecipe.value = false;
    };

    const isVisibleModalMint = ref(false);
    const showModaltMint = () => {
      isVisibleModalMint.value = true;
    };
    const closeModalMint = () => {
      isVisibleModalMint.value = false;
    };
    return {
      isVisibleModalRecipe,
      showModalRecipe,
      isVisibleModalMint,
      showModaltMint,
      closeModalRecipe,
      closeModalMint,
    };
  },
  components: {
    Recipe,
    ModalRecipe,
    ModalMint,
  },
});
</script>
