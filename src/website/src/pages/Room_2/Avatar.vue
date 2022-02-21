<template>
  <div ref="avatarDiv" class="mt-8 md:w-96 mx-auto w-60 h-auto"></div>
</template>

<script lang="ts">
import { defineComponent, onMounted, ref, computed, watchEffect } from "vue";
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
    accessory: {
      type: Object,
      required: false,
    },
  },
  setup(props, _) {
    const div = document.createElement("div");
    const avatarDiv = ref<HTMLDivElement>(div);

    onMounted(() => {
      //@ts-ignore
      avatarDiv.value.innerHTML = constructSVG(props.layers, props.body_name, props.style, props.accessory);
    });

    watchEffect(() => {
      //@ts-ignore
      avatarDiv.value.innerHTML = constructSVG(props.layers, props.body_name, props.style, props.accessory);
    });

    return { avatarDiv };
  },
});
</script>
