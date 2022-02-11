<template>
  <div class="flex flex-col flex-1">
    <!-- Not connected -->
    <div class="flex flex-col flex-1" v-if="!connected">
      <room-connexion></room-connexion>
    </div>
    <!-- Not loaded -->
    <div class="flex flex-col" v-else-if="!loaded">
      <loading-avatar></loading-avatar>
    </div>
    <!-- Room -->
    <div class="flex lg:flex-row flex-col min-h-screen justify-around" v-else>
      <div class="flex flex-col lg:w-1/2 lg:border-r-4 border-b-4 lg:border-b-0 border-gray-500">
        <avatar :body_name="body_name" :layers="layers" :style="style"></avatar>
        <slot-component :slots="slots"></slot-component>
      </div>
      <div class="flex flex-col lg:w-1/2">
        <h2 class="text-center 2xl:text-5xl lg:text-4xl md:text-3xl text-2xl font-bold text-gray-800 font-marker mt-16">Accessories 🎩</h2>
        <div class="grid grid-cols-3 mt-24 gap-x-4 gap-y-6 px-8" v-if="accessoryList.length > 0">
          <li
            v-for="accessory in accessoryList"
            :key="accessory.name"
            class="list-none flex flex-row flex-wrap cursor-pointer"
            :class="[selectedAccessory != undefined && selectedAccessory === accessory.name ? 'border-4 border-pink-400' : '']"
            @click="clickAccessory(accessory)"
          >
            <img class="w-44" :src="`https://po6n2-uiaaa-aaaaj-qaiua-cai.raw.ic0.app/?&tokenid=${accessory.token_identifier}`" alt="Accessory_card" />
          </li>
        </div>
        <h2 class="text-center px-8 text-2xl font-bold text-gray-800 mt-16">
          {{ message }}
        </h2>
      </div>
    </div>
  </div>
</template>

<script lang="ts">
import { defineComponent, computed, ref } from "vue";
import { useStore } from "vuex";
import RoomConnexion from "../../components/Connexion/RoomConnexion.vue";
import LoadingAvatar from "./LoadingAvatar.vue";
import Avatar from "./Avatar.vue";
import SlotComponent from "./Slots.vue";
import { nameToSlot } from "../../utils/list";
import { AccessoryListFromInventory, AccesoryInfos } from "../../types/inventory";
export default defineComponent({
  inheritAttrs: false,
  setup() {
    const store = useStore();
    const selectedAccessory = ref<AccesoryInfos | undefined>(undefined);

    const message = computed(() => {
      if (!selectedAccessory.value) {
        return "Please select an accessory";
      } else if (selectedAccessory.value.equipped) {
        return "This accessory is equipped";
      } else {
        let slot = nameToSlot(selectedAccessory.value.name);
        if (!slot) {
          return "This accessory is not compatible with the current room";
        }
        if (store.state.auth.equippedAccessories[slot].length > 0) {
          return "Cannot equip this accessory, you already have one in the slot : " + slot;
        }
        return "This accessory can be equipped in the slot : " + slot;
      }
    });

    function clickAccessory(accessory: AccesoryInfos) {
      selectedAccessory.value = accessory;
    }

    return {
      connected: computed(() => store.getters.isRoomConnected),
      loaded: computed(() => store.state.auth.avatarPreview && store.state.auth.equippedAccessories),
      token_identifier: computed(() => store.state.auth.avatarPreview.token_identifier),
      layers: computed(() => store.state.auth.avatarPreview.layers),
      slots: computed(() => store.state.auth.avatarPreview.slots),
      body_name: computed(() => store.state.auth.avatarPreview.body_name),
      style: computed(() => store.state.auth.avatarPreview.style),
      inventory: computed(() => store.state.auth.inventory),
      accessoryList: computed(() => AccessoryListFromInventory(store.state.auth.inventory)),
      selectedAccessory,
      message,
      clickAccessory,
    };
  },
  components: {
    RoomConnexion,
    LoadingAvatar,
    Avatar,
    SlotComponent,
  },
});
</script>
