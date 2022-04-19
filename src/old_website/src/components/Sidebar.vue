<template>
  <div class="flex flex-col bg-black bg-opacity-95 gap-y-10 py-8 z-10 items-center">
    <router-link to="/center">
      <button class="text-xl text-white bg-pink rounded py-4 cursor-pointer w-44">Avatar 👤</button>
    </router-link>
    <router-link to="/accessory">
      <button class="text-xl text-white bg-pink rounded py-4 cursor-pointer w-44">Accessory 🧢</button>
    </router-link>
    <router-link to="/lottery">
      <button class="text-xl text-white bg-pink rounded py-4 cursor-pointer w-44">Lottery 🎁</button>
    </router-link>
    <router-link to="/education">
      <button class="text-xl text-white bg-pink rounded py-4 cursor-pointer w-44">Education 💡</button>
    </router-link>
    <div class="font-bold flex flex-col items-center text-white">
      <div>© 2021 Dfinity community ∞</div>
      <div>
        <router-link to="/privacy"> Privacy policy </router-link>
      </div>
    </div>
  </div>
</template>

<script lang="ts">
import { defineComponent, ref } from "vue";
import ButtonCypher from "./Button/ButtonCypher.vue";
import RoundedButton from "./Button/RoundedButton.vue";
export default defineComponent({
  components: {
    ButtonCypher,
    RoundedButton,
  },
});
</script>
