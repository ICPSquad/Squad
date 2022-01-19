<template>
  <div class="flex flex-col justify-center items-center w-full">
    <h2
      class="
        text-center text-base text-gray-800
        font-bold
        md:text-2xl
        rounded
        py-3
        px-4
        md:px-8 md:mt-12
        mt-6
      "
    >
      Opacity ⚪️
    </h2>
    <slider></slider>
  </div>
</template>

<script lang="ts">
import { defineComponent } from "vue";
import Slider from "./Button/BaseSlider.vue";

export default defineComponent({
  components: {
    Slider,
  },
});
</script>
