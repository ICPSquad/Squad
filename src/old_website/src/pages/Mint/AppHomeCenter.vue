<template>
  <div class="flex flex-col justify-around flex-1">
    <div>
      <h3 class="mx-auto text-center lg:text-3xl md:text-2xl text-xl font-bold mt-16 text-gray-800">Here you can create and customize your own avatar 🧑‍🎨</h3>
    </div>
    <div class="flex flex-row w-full justify-around">
      <div class="flex flex-col items-center">
        <router-link to="/minter">
          <button class="lg:text-3xl md:text-2xl text-xl shadow-2xl font-marker text-white bg-pink-600 rounded md:py-6 md:px-14 md:mt-8 py-4 px-8 mt-4 cursor-pointer">Mint</button>
        </router-link>
        <h3 class="md:text-center text-xl font-bold mt-16 mx-6 text-gray-800">Design your avatar. 👤</h3>
      </div>
      <div class="flex flex-col items-center">
        <router-link to="/room">
          <button class="lg:text-3xl md:text-2xl text-xl shadow-2xl font-marker text-white bg-pink-600 rounded md:py-6 md:px-14 md:mt-8 py-4 px-8 mt-4 cursor-pointer">Room</button>
        </router-link>
        <h3 class="text-xl font-bold mt-16 mx-6 text-gray-800">Wear your accessories. 🎩</h3>
      </div>
    </div>
  </div>
</template>

<script lang="ts">
import { defineComponent } from "vue";
export default defineComponent({});
</script>
