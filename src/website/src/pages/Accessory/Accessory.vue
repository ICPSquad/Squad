<template>
  <div>
    <div v-if="!list">
      <accessory-example> </accessory-example>
      <button
        class="
          bg-black
          rounded-2xl
          flex flex-col
          items-center
          justify-center
          md:text-4xl
          text-sm
          font-marker
          text-white
          cursor-poin
          md:h-24
          h-16
          accessory-item
          lg:w-1/6
          w-1/3
          mx-auto
          mt-24
        "
        @click="showList"
      >
        Try
      </button>
    </div>
    <div v-else class="flex flex-row flex-wrap w-full gap-y-28 gap-x-8">
      <!-- TODO : Make a super title -->
      <li
        class="
          list-none
          flex flex-col
          w-1/2
          md:w-1/4
          mx-25
          border-2 border-gray-300
        "
        v-for="accessory in accessories"
        :key="accessory[0]"
      >
        <img :src="`/accessory/${accessory[0]}.jpg`" alt="Error" />
        <card-blueprint :blueprint="accessory[1].blueprint"></card-blueprint>
        <button
          class="
            lg:text-3xl
            md:text-2xl
            text-xl
            shadow-xl
            mb-4
            font-marker
            text-gray-800
            bg-pink-600
            rounded
            py-6
            px-8
            mt-8
            w-1/2
            mx-auto
            cursor-pointer
          "
          @click="createAccessory(accessory[0])"
        >
          Create 🧪
        </button>
      </li>
    </div>
  </div>
</template>

<script lang="ts">
import { defineComponent, ref } from "vue";
import {
  getAllAccessory,
  AccessoryInfos,
  requestCreateAccessory,
} from "../../api/accessory";
import { useStore } from "vuex";
import Inventory from "../../components/Inventory/Inventory.vue";
import ButtonCypher from "../../components/Button/ButtonCypher.vue";
import AccessoryExample from "./AccessoryExample.vue";
import CardBlueprint from "./CardBlueprint.vue";
export default defineComponent({
  setup() {
    const store = useStore();
    const list = ref(false);
    const accessories = ref<Array<[string, AccessoryInfos]>>([]);

    const loadAccessory = async () => {
      let result = await getAllAccessory();
      accessories.value = result;
    };

    const showList = () => {
      list.value = true;
      loadAccessory();
    };

    function checkIfAuthenticated(): boolean {
      let principal = store.getters.getPrincipal;
      if (principal) {
        return true;
      } else {
        return false;
      }
    }

    const createAccessory = async (name: string) => {
      if (
        confirm(
          "Are you sure you want to create this accessory? \n The materials will be automatically removed from your inventory."
        )
      )
        if (!checkIfAuthenticated()) {
          alert("You need to be authenticated to create an accessory");
          return;
        }

      let result = await requestCreateAccessory(name);
      // TODO : improve UX for this
      alert(result);
    };

    return { list, showList, accessories, createAccessory };
  },
  components: {
    Inventory,
    ButtonCypher,
    AccessoryExample,
    CardBlueprint,
  },
});
</script>

<style scoped>
.accessory-item:hover {
  transform: scale(0.95);
}
</style>
