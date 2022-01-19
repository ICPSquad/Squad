<template>
  <div
    class="w-full grid grid-cols-2 grid-rows-3 px-8 gap-x-5 gap-y-8 mb-4"
    v-if="accessory_array.length > 0"
  >
    <li v-for="accessory in accessory_array" :key="accessory[0]">
      <a
        :href="`https://po6n2-uiaaa-aaaaj-qaiua-cai.raw.ic0.app/nft/${accessory[0]}`"
        target="_blank"
      >
        <img :src="`cards/accessories/${accessory[1]}.svg`" alt="Error" />
      </a>
    </li>
  </div>
</template>

<script lang="ts">
import { defineComponent } from "vue";

export default defineComponent({
  props: ["accessory_array"],
  setup(props) {
    const accessory_array = props.accessory_array;

    return {
      accessory_array,
    };
  },
});
</script>
