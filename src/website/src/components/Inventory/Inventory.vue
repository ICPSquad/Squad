<template>
  <div class="flex flex-row justify-end w-full">
    <div class="w-full md:w-1/4 bg-black absolute z-10">
      <div>
        <h2 class="font-bold text-5xl my-8 text-white text-center">
          Your inventory
        </h2>
      </div>
      <div class="flex flex-row justify-around mb-12">
        <button
          class="
            md:text-2xl
            shadow-2xl
            text-gray-800
            font-bold
            bg-pink-600
            rounded
            py-4
            px-2
          "
          @click="menuMaterial"
        >
          Materials
        </button>
        <button
          class="
            md:text-2xl
            shadow-2xl
            text-gray-800
            font-bold
            bg-pink-600
            rounded
            py-2
            px-2
          "
          @click="menuAccessories"
        >
          Accessories
        </button>
      </div>

      <div v-if="connected && materials">
        <materials :object_inventory="object_inventory_material"></materials>
      </div>
      <div v-else-if="connected && accessory">
        <accessories :accessory_array="array_inventory_accesory"></accessories>
      </div>
      <div class="justify-self-end items-end">
        <wallet @load="loadInventory" @connexion="loadInventory"></wallet>
      </div>
    </div>
  </div>
</template>

<script lang="ts">
import { computed, defineComponent, ref } from "vue";
import { useStore } from "vuex";
import Wallet from "../Wallet/Connect.vue";

// Components
import Materials from "./AppMaterials.vue";
import Accessories from "./AppAccessories.vue";

import {
  getObjectForMaterialComponent,
  getArrayforAccessoryComponent,
} from "../../types/inventory";

export default defineComponent({
  setup() {
    const store = useStore();
    const inventory = computed(() => store.getters.getInventory);

    const object_inventory_material = computed(() => {
      return getObjectForMaterialComponent(inventory.value);
    });

    const array_inventory_accesory = computed(() => {
      return getArrayforAccessoryComponent(inventory.value);
    });

    const materials = ref(true);
    const accessory = ref(false);

    const menuMaterial = () => {
      materials.value = true;
      accessory.value = false;
    };
    const menuAccessories = () => {
      materials.value = false;
      accessory.value = true;
    };

    return {
      connected: computed(() => store.getters.isInventoryConnected),
      loadInventory: () => store.dispatch("loadInventory"),
      inventory,
      accessory,
      materials,
      menuMaterial,
      menuAccessories,
      object_inventory_material,
      array_inventory_accesory,
    };
  },
  components: {
    Wallet,
    Materials,
    Accessories,
  },
});
</script>
