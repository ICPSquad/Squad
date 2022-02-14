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
        <avatar :body_name="body_name" :layers="layers" :style="style" :accessory="selectedAccessory"></avatar>
        <slot-component></slot-component>
      </div>
      <div class="flex flex-col lg:w-1/2 items-center">
        <div>
          <h2 class="text-center 2xl:text-5xl lg:text-4xl md:text-3xl text-2xl font-bold text-gray-800 font-marker mt-8">Accessories 🎩</h2>
          <div class="grid grid-cols-3 gap-x-4 gap-y-6 px-8 mt-8" v-if="accessoryList.length > 0">
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
        </div>

        <h2 class="text-center px-8 text-2xl font-bold text-gray-800 mt-8">
          {{ message }}
        </h2>
        <button
          class="text-2xl shadow-xl text-black font-bold bg-pink-600 rounded px-8 py-4 w-44 mt-8"
          :class="[waiting ? 'animate-pulse cursor-wait' : '']"
          @click="buttonAction"
          v-if="buttonState.show"
        >
          {{ buttonState.text }}
        </button>
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
    const waiting = ref(false);
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

    function canBeEquipped(accessory: AccesoryInfos) {
      let slot = nameToSlot(accessory.name);
      if (!slot) {
        return false;
      }
      if (store.state.auth.equippedAccessories[slot].length > 0) {
        return false;
      }
      return true;
    }

    function clickAccessory(accessory: AccesoryInfos) {
      selectedAccessory.value = accessory;
    }

    const buttonState = computed(() => {
      if (!selectedAccessory.value) {
        return { show: false, text: "" };
      }
      if (waiting.value) {
        return { show: true, text: "Wait..." };
      }
      if (selectedAccessory.value.equipped) {
        return { show: true, text: "Remove" };
      }
      let slot = nameToSlot(selectedAccessory.value.name);
      if (!slot) {
        return { show: false, text: "" };
      }
      if (store.state.auth.equippedAccessories[slot].length > 0) {
        return { show: false, text: "" };
      }
      return { show: true, text: "Wear 🕶" };
    });

    const buttonAction = async () => {
      if (!selectedAccessory.value) {
        return;
      }
      if (selectedAccessory.value.equipped) {
        if (
          confirm(
            "Are you sure you want to remove this accessory ? It will consume 1 wear point and you will loose all the stats associated with it. You will be able to wear it again if you have enough wear points."
          )
        ) {
          let actor = store.getters.getAuthenticatedActor_material;
          let token_identifier_avatar = store.state.auth.avatarPreview.token_identifier;
          let token_identifier_accessory = selectedAccessory.value.token_identifier;
          const result = await actor.removeAccessory(token_identifier_accessory, token_identifier_avatar);
          if (result.hasOwnProperty("err")) {
            alert(JSON.stringify(result.err));
          } else {
            alert("Accessory has been successfully equipped, congratulations ! Take a look at your avatar.");
          }
        }
      } else {
        if (confirm("Are you sure you want to equip this accessory? It will consume 1 wear point. You will be able to remove it later.")) {
          waiting.value = true;
          let actor = store.getters.getAuthenticatedActor_material;
          let token_identifier_avatar = store.state.auth.avatarPreview.token_identifier;
          let token_identifier_accessory = selectedAccessory.value.token_identifier;
          const result = await actor.wearAccessory(token_identifier_accessory, token_identifier_avatar);
          if (result.hasOwnProperty("err")) {
            alert(JSON.stringify(result.err));
          } else {
            alert("Accessory has been successfully equipped, congratulations ! Take a look at your avatar.");
          }
        }
      }
    };

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
      buttonState,
      buttonAction,
      waiting,
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
