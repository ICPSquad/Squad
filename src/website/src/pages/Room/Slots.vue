<template>
  <div class="flex flex-col mb-8">
    <div class="flex flex-row justify-around flex-wrap">
      <div class="flex flex-col items-center">
        <div class="border-4 border-pink-400 w-44 mt-4">
          <svg viewBox="0 0 800 800">
            <use :href="Hat"></use>
          </svg>
        </div>
      </div>
      <div class="flex flex-col items-center">
        <div class="border-4 border-pink-400 w-44 mt-4">
          <svg viewBox="0 0 800 800">
            <use :href="Eyes"></use>
          </svg>
        </div>
      </div>
      <div class="flex flex-col items-center">
        <div class="border-4 border-pink-400 w-44 mt-4">
          <svg viewBox="0 0 800 800">
            <use :href="Face"></use>
          </svg>
        </div>
      </div>
    </div>
    <div class="flex flex-row justify-around flex-wrap">
      <div class="flex flex-col items-center">
        <div class="border-4 border-pink-400 w-44 mt-4">
          <svg viewBox="0 0 800 800">
            <use :href="Body"></use>
          </svg>
        </div>
      </div>
      <div class="flex flex-col items-center">
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
  setup() {
    const store = useStore();
    const equiped = computed(() => store.getters.getEquipedAccessory);

    const Hat = computed(() => {
      if (equiped.value.Hat[0]) {
        return `#${equiped.value.Hat[0]}`;
      } else {
        return store.getters.getHatId;
      }
    });

    const Eyes = computed(() => {
      if (equiped.value.Eyes[0]) {
        return `#${equiped.value.Eyes[0]}`;
      } else {
        return store.getters.getEyesId;
      }
    });

    const Face = computed(() => {
      if (equiped.value.Face[0]) {
        return `#${equiped.value.Face[0]}`;
      } else {
        return store.getters.getFaceId;
      }
    });

    const Body = computed(() => {
      if (equiped.value.Body[0]) {
        return `#${equiped.value.Body[0]}`;
      } else {
        return store.getters.getBodyId;
      }
    });

    const Misc = computed(() => {
      if (equiped.value.Misc[0]) {
        return `#${equiped.value.Misc[0]}`;
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
