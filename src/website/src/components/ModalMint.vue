<template>
  <div class="fixed top-0 bottom-0 left-0 right-0 flex flex-col items-center justify-center bg-opacity-30 bg-black">
    <div class="modal bg-white shadow-xl rounded-xl flex flex-col">
      <header class="border-gray-600 border-b-4 flex flex-row text-5xl font-bold text-gray-800 items-center pl-8 justify-between">
        <h3 class="text-center text-2xl font-bold text-gray-800">{{ name }}</h3>
        <button @click="close" class="bg-pink-600 p-2 m-2 rounded-xl">X</button>
      </header>
      <!-- Description -->
      <div class="flex flex-col text-center font-bold text-xl text-gray-800 px-8 py-4">
        <span style="white-space: pre">{{ message }}</span>
      </div>
      <div class="mx-auto">
        <button class="text-2xl shadow-2xl text-gray-800 bg-pink-600 rounded py-3 px-8 mt-6 cursor-pointer max-w-2xl mb-6" @click="modify">Confirm</button>
      </div>
    </div>
  </div>
</template>

<script lang="ts">
import { defineComponent, ref } from "vue";

export default defineComponent({
  emits: ["close"],
  props: {
    name: {
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

    const message = ref<string>("You're about to mint " + props.name + ".\nIt will burn the corresponding materials from your wallet.\n ⚠️This action is irreversible.\nAre you sure?");

    return { close, message };
  },
});
</script>
