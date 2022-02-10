<template>
  <div class="flex flex-col mb-8">
    <div class="flex flex-row justify-around flex-wrap">
      <div class="flex flex-col items-center">
        <h3
          class="
            w-2/3
            md:w-1/2
            mx-auto
            text-center
            lg:text-3xl
            md:text-2xl
            text-xl
            font-bold
            mt-8
            text-gray-800
          "
        >
          Hat {{ isSlotEquiped("Hat") ? "🔐" : "" }}
        </h3>
        <div class="border-4 border-pink-400 w-44 mt-4">
          <svg viewBox="0 0 800 800">
            <use :href="Hat"></use>
          </svg>
        </div>
        <button
          v-if="showButton('Hat')"
          class="
            lg:text-3xl
            md:text-2xl
            text-xl text-white
            bg-pink-600
            rounded
            py-4
            px-4
            mt-4
          "
          @click="removeSlot('Hat')"
        >
          Remove
        </button>
      </div>
      <div class="flex flex-col items-center">
        <h3
          class="
            w-2/3
            md:w-1/2
            mx-auto
            text-center
            lg:text-3xl
            md:text-2xl
            text-xl
            font-bold
            mt-8
            text-gray-800
          "
        >
          Eyes {{ isSlotEquiped("Eyes") ? "🔐" : "" }}
        </h3>
        <div class="border-4 border-pink-400 w-44 mt-4">
          <svg viewBox="0 0 800 800">
            <use :href="Eyes"></use>
          </svg>
        </div>
        <button
          v-if="showButton('Eyes')"
          class="
            lg:text-3xl
            md:text-2xl
            text-xl text-white
            bg-pink-600
            rounded
            py-4
            px-4
            mt-4
          "
          @click="removeSlot('Eyes')"
        >
          Remove
        </button>
      </div>
      <div class="flex flex-col items-center">
        <h3
          class="
            w-2/3
            md:w-1/2
            mx-auto
            text-center
            lg:text-3xl
            md:text-2xl
            text-xl
            font-bold
            mt-8
            text-gray-800
          "
        >
          Face {{ isSlotEquiped("Face") ? "🔐" : "" }}
        </h3>
        <div class="border-4 border-pink-400 w-44 mt-4">
          <svg viewBox="0 0 800 800">
            <use :href="Face"></use>
          </svg>
        </div>
        <button
          :class="
            showButton('Face') ? 'cursor-pointer bg-pink-600' : 'invisible'
          "
          class="
            lg:text-3xl
            md:text-2xl
            text-xl text-white
            rounded
            py-4
            px-4
            mt-4
          "
          @click="showButton ? removeSlot('Face') : null"
        >
          Remove
        </button>
      </div>
    </div>
    <div class="flex flex-row justify-around flex-wrap">
      <div class="flex flex-col items-center">
        <h3
          class="
            w-2/3
            md:w-1/2
            mx-auto
            text-center
            lg:text-3xl
            md:text-2xl
            text-xl
            font-bold
            mt-16
            text-gray-800
          "
        >
          Body {{ isSlotEquiped("Body") ? "🔐" : "" }}
        </h3>
        <div class="border-4 border-pink-400 w-44 mt-4">
          <svg viewBox="0 0 800 800">
            <use :href="Body"></use>
          </svg>
        </div>
        <button
          v-if="showButton('Body')"
          class="
            lg:text-3xl
            md:text-2xl
            text-xl text-white
            bg-pink-600
            rounded
            py-4
            px-4
            mt-4
          "
          @click="removeSlot('Body')"
        >
          Remove
        </button>
      </div>
      <div class="flex flex-col items-center">
        <h3
          class="
            w-2/3
            md:w-1/2
            mx-auto
            text-center
            lg:text-3xl
            md:text-2xl
            text-xl
            font-bold
            mt-16
            text-gray-800
          "
        >
          Special {{ isSlotEquiped("Misc") ? "🔐" : "" }}
        </h3>
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
    const slots = computed(() => store.getters.getSlots);

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

    function showButton(slot: string) {
      if (equiped.value[slot][0]) {
        return false;
      } else if (slots.value[slot] == null) {
        return false;
      } else {
        return true;
      }
    }

    function removeSlot(slot: string) {
      let accessory = slots.value[slot];
      let slots_accessory = accessory.slots;
      slots_accessory.forEach((slot: string) => {
        store.commit("clearSlot", slot);
      });
    }

    const isSlotEquiped = (slot: string) => {
      if (equiped.value[slot][0]) {
        return true;
      } else {
        return false;
      }
    };

    return {
      Hat,
      Eyes,
      Face,
      Body,
      Misc,
      showButton,
      removeSlot,
      isSlotEquiped,
    };
  },
});
</script>
