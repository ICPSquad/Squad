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
    <div class="flex flex-row justify-around flex-wrap">
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
      if (store.state.auth.equippedAccessories.Hat[0]) {
        return `#${store.state.auth.equippedAccessories.Hat[0]}`;
      } else {
        return store.getters.getHatId;
      }
    });

    const Eyes = computed(() => {
      if (store.state.auth.equippedAccessories.Eyes[0]) {
        return `#${store.state.auth.equippedAccessories.Eyes[0]}`;
      } else {
        return store.getters.getEyesId;
      }
    });

    const Face = computed(() => {
      if (store.state.auth.equippedAccessories.Face[0]) {
        return `#${store.state.auth.equippedAccessories.Hat[0]}`;
      } else {
        return store.getters.getFaceId;
      }
    });

    const Body = computed(() => {
      if (store.state.auth.equippedAccessories.Body[0]) {
        return `#${store.state.auth.equippedAccessories.Body[0]}`;
      } else {
        return store.getters.getBodyId;
      }
    });

    const Misc = computed(() => {
      if (store.state.auth.equippedAccessories.Misc[0]) {
        return `#${store.state.auth.equippedAccessories.Misc[0]}`;
      } else {
        return store.getters.getMiscId;
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
