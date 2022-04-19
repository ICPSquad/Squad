<template>
  <div class="flex flex-row h-36 w-full">
    <li
      v-for="(material, index) in blueprint"
      :key="index"
      class="list-none w-1/4"
    >
      <img
        class="h-full w-auto"
        :src="`material/${material}.svg`"
        alt="Error"
      />
    </li>
  </div>
</template>

<script lang="ts">
import { defineComponent } from "vue";

export default defineComponent({
  props: {
    blueprint: {
      type: Array,
      required: true,
    },
  },
  setup() {},
});
</script>
