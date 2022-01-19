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
        Welcome to the Acessory center !
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
        Here you can mint accessories and receive airdrops. 👑
        <br />
      </h3>
    </div>
    <div class="flex flex-row w-full md:justify-around py-6 px-6">
      <div class="flex flex-col items-center">
        <router-link to="/airdrop">
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
              md:py-6 md:px-8 md:mt-8
              py-4
              px-4
              mt-4
              cursor-pointer
            "
          >
            Airdrop
          </button>
        </router-link>
        <h3
          class="
            md:w-1/2
            text-center
            lg:text-3xl
            md:text-2xl
            text-sm
            font-bold
            mt-16
            text-gray-800
          "
        >
          Receive your gifts if you've participated in the preorder ! 🎁
        </h3>
      </div>
      <div>
        <div class="flex flex-col items-center">
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
            @click="labMessage"
          >
            Lab
          </button>
          <h3
            class="
              md:w-1/2
              text-center
              lg:text-3xl
              md:text-2xl
              text-sm
              font-bold
              mt-16
              text-gray-800
            "
          >
            Combine your elements to create accessories. 🧪
          </h3>
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
