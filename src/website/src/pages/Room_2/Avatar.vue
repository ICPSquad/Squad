<template>
  <div ref="avatarDiv" class="mt-8 md:w-96 mx-auto w-60 h-auto border-4 border-pink-300 bg-white"></div>
</template>

<script lang="ts">
import { defineComponent, onMounted, ref, computed, watchEffect } from "vue";
import { useStore } from "vuex";
import { constructSVG } from "../../utils/svg_new";

export default defineComponent({
  props: {
    layers: {
      type: Array,
      default: () => [],
    },
    body_name: {
      type: String,
      required: true,
    },
    style: {
      type: String,
      required: true,
    },
  },
  setup(props, _) {
    const div = document.createElement("div");
    const avatarDiv = ref<HTMLDivElement>(div);

    const store = useStore();
    const slots = computed(() => store.getters.getSlots);

    onMounted(() => {
      //@ts-ignore
      avatarDiv.value.innerHTML = constructSVG(props.layers, props.body_name, props.style);
    });

    watchEffect(() => {
      //@ts-ignore
      avatarDiv.value.innerHTML = constructSVG(props.layers, props.body_name, props.style);
    });

    return { avatarDiv, slots };
  },
});
</script>
