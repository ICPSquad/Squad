<template>
  <div class="flex flex-col mb-4">
    <div class="flex flex-row justify-around flex-wrap">
      <div class="flex flex-col items-center">
        <h3 class="w-2/3 md:w-1/2 mx-auto text-center lg:text-3xl md:text-2xl text-xl font-bold mt-8 text-gray-800">Hat</h3>
        <div class="border-4 border-pink-400 w-44 mt-4">
          <svg viewBox="0 0 800 800">
            <use :href="Hat"></use>
          </svg>
        </div>
      </div>
      <div class="flex flex-col items-center">
        <h3 class="w-2/3 md:w-1/2 mx-auto text-center lg:text-3xl md:text-2xl text-xl font-bold mt-8 text-gray-800">Eyes</h3>
        <div class="border-4 border-pink-400 w-44 mt-4">
          <svg viewBox="0 0 800 800">
            <use :href="Eyes"></use>
          </svg>
        </div>
      </div>
      <div class="flex flex-col items-center">
        <h3 class="w-2/3 md:w-1/2 mx-auto text-center lg:text-3xl md:text-2xl text-xl font-bold mt-8 text-gray-800">Face</h3>
        <div class="border-4 border-pink-400 w-44 mt-4">
          <svg viewBox="0 0 800 800">
            <use :href="Face"></use>
          </svg>
        </div>
      </div>
    </div>
    <div class="flex flex-row justify-around flex-wrap mt-6">
      <div class="flex flex-col items-center">
        <h3 class="w-2/3 md:w-1/2 mx-auto text-center lg:text-3xl md:text-2xl text-xl font-bold text-gray-800">Body</h3>
        <div class="border-4 border-pink-400 w-44 mt-4">
          <svg viewBox="0 0 800 800">
            <use :href="Body"></use>
          </svg>
        </div>
      </div>
      <div class="flex flex-col items-center">
        <h3 class="w-2/3 md:w-1/2 mx-auto text-center lg:text-3xl md:text-2xl text-xl font-bold text-gray-800">Special</h3>
        <div class="border-4 border-pink-400 w-44 mt-4">
          <svg viewBox="0 0 800 800">
            <use :href="Misc"></use>
          </svg>
        </div>
      </div>
    </div>
  </div>
</template>

<script lang="ts">
import { defineComponent, computed } from "vue";
import { useStore } from "vuex";

export default defineComponent({
  props: {},
  setup() {
    const store = useStore();

    const Hat = computed(() => {
      if (store.state.auth.avatarInfo !== null) {
        return `#${store.state.auth.avatarInfo.slots.Hat[0]}`;
      } else {
        return "#empty";
      }
    });

    const Eyes = computed(() => {
      if (store.state.auth.avatarInfo !== null) {
        return `#${store.state.auth.avatarInfo.slots.Eyes[0]}`;
      } else {
        return "#empty";
      }
    });

    const Face = computed(() => {
      if (store.state.auth.avatarInfo !== null) {
        return `#${store.state.auth.avatarInfo.slots.Face[0]}`;
      } else {
        return "#empty";
      }
    });

    const Body = computed(() => {
      if (store.state.auth.avatarInfo !== null) {
        return `#${store.state.auth.avatarInfo.slots.Body[0]}`;
      } else {
        return "#empty";
      }
    });

    const Misc = computed(() => {
      if (store.state.auth.avatarInfo !== null) {
        return `#${store.state.auth.avatarInfo.slots.Misc[0]}`;
      } else {
        return "#empty";
      }
    });

    return {
      Hat,
      Eyes,
      Face,
      Body,
      Misc,
    };
  },
});
</script>
