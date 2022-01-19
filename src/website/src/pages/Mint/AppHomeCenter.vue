<template>
  <div class="flex flex-col justify-around flex-1">
    <div>
      <h2
        class="
          text-center
          2xl:text-5xl
          lg:text-4xl
          md:text-3xl
          text-2xl
          font-bold
          text-gray-800
          font-marker
        "
      >
        Welcome to the Avatar center !
      </h2>
      <h3
        class="
          w-2/3
          md:w-1/2
          mx-auto
          text-center
          lg:text-3xl
          md:text-2xl
          text-xl
          font-bold
          mt-16
          text-gray-800
        "
      >
        Here you can create and customize your own avatar NFT. 🧑‍🎨
        <br />
      </h3>
    </div>
    <div class="flex flex-row w-full justify-around">
      <div class="flex flex-col items-center">
        <router-link to="/minter">
          <button
            class="
              lg:text-3xl
              md:text-2xl
              text-xl
              shadow-2xl
              font-marker
              text-white
              bg-pink-600
              rounded
              md:py-6 md:px-14 md:mt-8
              py-4
              px-8
              mt-4
              cursor-pointer
            "
          >
            Mint
          </button>
        </router-link>
        <h3
          class="
            md:w-1/2 md:text-center
            lg:text-3xl
            md:text-2xl
            text-sm
            font-bold
            mt-16
            mx-6
            text-gray-800
          "
        >
          Use your creativity to design your avatar. 👤
        </h3>
      </div>
      <div class="flex flex-col items-center">
        <router-link to="/room">
          <button
            class="
              lg:text-3xl
              md:text-2xl
              text-xl
              shadow-2xl
              font-marker
              text-white
              bg-pink-600
              rounded
              md:py-6 md:px-14 md:mt-8
              py-4
              px-8
              mt-4
              cursor-pointer
            "
          >
            Room
          </button>
        </router-link>
        <h3
          class="
            md:w-1/2 md:text-center
            lg:text-3xl
            md:text-2xl
            text-sm
            font-bold
            mt-16
            mx-6
            text-gray-800
          "
        >
          Improve your avatar with accessories. 🎩
        </h3>
      </div>
    </div>
  </div>
</template>

<script lang="ts">
import { defineComponent } from "vue";

export default defineComponent({
  setup() {},
});
</script>
