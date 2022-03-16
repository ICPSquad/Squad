<template>
  <div class="flex flex-col justify-around flex-1">
    <div>
      <h3 class="mx-auto text-center lg:text-3xl md:text-2xl text-xl font-bold mt-16 text-gray-800">Here you can mint accessories and receive airdrops. 👑</h3>
    </div>
    <div class="flex flex-row w-full justify-around">
      <div class="flex flex-col items-center">
        <router-link to="/airdrop">
          <button class="lg:text-3xl md:text-2xl text-xl shadow-2xl font-marker text-white bg-pink-600 rounded md:py-6 md:px-8 md:mt-8 py-4 px-4 mt-4 cursor-pointer">Airdrop</button>
        </router-link>
        <h3 class="text-xl font-bold mt-16 text-gray-800">Airdrop from preorder.🎁</h3>
      </div>
      <div>
        <div class="flex flex-col items-center">
          <button class="lg:text-3xl md:text-2xl text-xl shadow-2xl font-marker text-white bg-pink-600 rounded md:py-6 md:px-14 md:mt-8 py-4 px-8 mt-4 cursor-pointer" @click="labMessage">Lab</button>
          <h3 class="text-xl font-bold mt-16 text-gray-800">Mint new accessories. 🧪</h3>
        </div>
      </div>
    </div>
  </div>
</template>

<script lang="ts">
import { defineComponent } from "vue";

export default defineComponent({
  setup() {
    const labMessage = () => {
      alert("Coming soon ! 🧑‍🔬");
    };
    return {
      labMessage,
    };
  },
});
</script>
