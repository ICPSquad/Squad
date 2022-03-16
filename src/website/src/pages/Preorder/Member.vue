<template>
  <div class="flex flex-col flex-1 w-full bg-gradient-to-l from-gray-600 via-gray-900 to-black lg:text-6xl md:text-4xl text-2xl font-semibold text-white justify-around">
    <h3 class="text-center md:mb-16 mt-8 mb-8 lg:text-5xl md:text- 3xl text-2xl">You have successfully joined the squad 🎉</h3>
    <div class="w-full flex flex-row justify-around items-center">
      <router-link to="/">
        <button class="lg:text-3xl md:text-2xl text-xl shadow-2xl font-marker text-white bg-pink-600 rounded py-6 px-8 mt-8 cursor-pointer">Home 🏠</button>
      </router-link>
      <router-link to="/center">
        <button class="lg:text-3xl md:text-2xl text-xl shadow-2xl font-marker text-white bg-pink-600 rounded py-6 px-8 mt-8 cursor-pointer">Mint 🎨</button>
      </router-link>
    </div>
  </div>
</template>

<script>
export default {};
</script>
