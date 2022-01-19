<template>
  <div
    ref="avatarDiv"
    class="mt-8 md:w-96 mx-auto w-60 h-auto border-4 border-pink-300 bg-white"
  ></div>
</template>

<script lang="ts">
import { defineComponent, onMounted, ref, computed, watchEffect } from "vue";
import { useStore } from "vuex";
import { redrawSvg } from "../../utils/svg";

export default defineComponent({
  setup() {
    const div = document.createElement("div");
    const avatarDiv = ref<HTMLDivElement>(div);

    const store = useStore();
    const slots = computed(() => store.getters.getSlots);

    onMounted(() => {
      avatarDiv.value.innerHTML = redrawSvg();
    });

    watchEffect(() => {
      avatarDiv.value.innerHTML = redrawSvg();
    });

    return { avatarDiv, slots };
  },
});
</script>
