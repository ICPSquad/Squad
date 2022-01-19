<template>
  <div class="flex flex-col" v-if="!connected">
    <room-connexion></room-connexion>
  </div>
  <div class="flex flex-col" v-else-if="!loaded">
    <loading-avatar></loading-avatar>
  </div>
  <div class="flex lg:flex-row flex-col min-h-screen justify-around" v-else>
    <div
      class="
        flex flex-col
        lg:w-1/2 lg:border-r-4
        border-b-4
        lg:border-b-0
        border-gray-500
      "
    >
      <avatar></avatar>
      <slot-component></slot-component>
    </div>
    <div class="flex flex-col lg:w-1/2">
      <h2
        class="
          text-center
          2xl:text-5xl
          lg:text-4xl
          md:text-3xl
          text-2xl
          font-bold
          text-gray-800
          font-marker
          mt-16
        "
      >
        Accessories 🎩
      </h2>
      <div class="flex flex-col items-center">
        <div
          class="
            flex
            lg:flex-row
            flex-wrap flex-col
            justify-around
            gap-x-6 gap-y-8
            mt-12
            px-6
          "
        >
          <li
            v-for="type in list_types_accessories"
            :key="type.name"
            class="list-none"
          >
            <button
              class="
                md:text-2xl
                shadow-xl
                text-gray-800
                font-bold
                bg-pink-400
                rounded
                px-8
                py-4
                w-full
                lg:px-14 lg:py-6 lg:w-auto
              "
              :class="[selectedType.name == type.name ? 'bg-pink-600' : '']"
              @click="changeSelectedType(type)"
            >
              {{ type.name }}
            </button>
          </li>
        </div>
        <h2
          class="
            lg:w-2/3
            px-6
            lg:mt-16
            mt-8
            mx-auto
            text-center text-gray-800 text-2xl
            font-bold
          "
        >
          {{ selectedType.message }}
        </h2>
        <div
          class="flex flex-row flex-wrap justify-center mt-24 gap-x-4 gap-y-6"
          v-if="accessoryList.length > 0 && conflictSlots.length == 0"
        >
          <li
            v-for="accessory in accessoryList"
            :key="accessory.name"
            class="list-none flex flex-row flex-wrap cursor-pointer"
            @click="changeSelectedAccessory(accessory)"
            :class="[
              selectedAccessory != undefined &&
              selectedAccessory.name === accessory.name
                ? 'border-4 border-pink-400'
                : 'border-4 border-gray-400',
            ]"
          >
            <svg
              viewBox="0 0 800 800"
              xmlns="http://www.w3.org/2000/svg"
              width="200px"
            >
              <use :href="`#${accessory.name}`"></use>
            </svg>
          </li>
        </div>
        <div
          v-else-if="conflictSlots.length > 0"
          class="flex flex-row flex-wrap justify-center mt-24 gap-x-4 gap-y-6"
        >
          <h2 class="text-center px-8 text-2xl font-bold text-gray-800 mt-16">
            You cannot add this type of accessory. <br />
            There is a conflit with an already occuped slot :
            {{ conflictSlots[0] }}
          </h2>
        </div>
      </div>
      <div v-if="accessoryList.length > 0 && conflictSlots.length == 0">
        <h2 class="py-12 text-center text-gray-800 text-3xl font-bold">
          {{
            selectedAccessory == undefined
              ? "Select an accessory to check how it fits you 😎"
              : selectedAccessory.description
          }}
        </h2>
      </div>
      <div v-if="ownAccessory" class="mx-auto">
        <button
          class="
            md:text-2xl
            shadow-xl
            text-gray-800
            font-bold
            bg-pink-600
            rounded
            px-8
            py-4
            w-full
            lg:px-14 lg:py-6 lg:w-auto
          "
          :class="[waiting ? 'animate-pulse cursor-wait' : '']"
          @click="wearAccessory(selectedAccessory.name)"
        >
          {{ waiting ? "Wait.. " : "Wear 👈" }}
        </button>
      </div>
    </div>
  </div>
</template>

<script lang="ts">
import { defineComponent, computed, ref } from "vue";
import { useStore } from "vuex";
import { accessories } from "../../utils/list";
import { list_types_accessories, TypesAccessories, slotsEqual } from "./types";
import { Accessory } from "../../types/accessories";
import {
  isAccessoryInInventory,
  getTokenIdentifier,
} from "../../types/inventory";
import LoadingAvatar from "./LoadingAvatar.vue";
import Avatar from "./Avatar.vue";
import SlotComponent from "./Slots.vue";
import RoomConnexion from "../../components/Connexion/RoomConnexion.vue";

export default defineComponent({
  setup() {
    const store = useStore();
    const inventory = computed(() => store.getters.getInventory);

    const waiting = ref<boolean>(false);

    const selectedType = ref<TypesAccessories>(list_types_accessories[0]);
    function changeSelectedType(new_type: TypesAccessories) {
      selectedAccessory.value = undefined;
      selectedType.value = new_type;
    }

    const accessoryList = computed(() => {
      selectedType.value;
      return accessories.filter((accessory) => {
        return slotsEqual(accessory.slots, selectedType.value.slots);
      });
    });

    const selectedAccessory = ref<Accessory>();
    const changeSelectedAccessory = (accessory: Accessory) => {
      selectedAccessory.value = accessory;
      store.commit("setAccessory", accessory);
    };

    const ownAccessory = computed(() => {
      if (selectedAccessory.value == undefined) return false;
      return isAccessoryInInventory(
        selectedAccessory.value.name,
        inventory.value
      );
    });

    const wearAccessory = async (accessory_name: string) => {
      if (waiting.value) return;
      if (
        confirm(
          `You are about to wear  ${accessory_name}. It will equip the corresponding slot(s). Are you sure? This action cannot be undone !`
        )
      ) {
        waiting.value = true;
        let token_accessory = getTokenIdentifier(
          accessory_name,
          inventory.value
        );
        let token_avatar = store.getters.getTokenAvatar;
        let actor = store.getters.getAuthenticatedActor_material;
        if (
          token_avatar == null ||
          token_accessory == "Null" ||
          actor == null
        ) {
          waiting.value = false;
          throw new Error(
            "Avatar token / accessory token / actor -> not found"
          );
        }

        let request = await actor.wearAccessory(token_accessory, token_avatar);
        if (request.err) {
          waiting.value = false;
          alert(JSON.stringify(request.err));
        } else {
          waiting.value = false;
          alert("Accessory has been successfuly equiped!");
        }
        return;
      }
    };

    //To prevent people for overwritting their current accessory
    // Returns an array of conflictual slots with the selected type.
    const equiped = computed(() => store.getters.getEquipedAccessory);

    const conflictSlots = computed(() => {
      let equiped_slots = equiped.value;
      let types_slots = selectedType.value.slots;
      let conflict_slots: string[] = [];
      for (let i = 0; i < types_slots.length; i++) {
        if (equiped_slots[types_slots[i]].length > 0) {
          conflict_slots.push(types_slots[i]);
        }
      }
      return conflict_slots;
    });

    return {
      connected: computed(() => store.getters.isRoomConnected),
      loaded: computed(() => store.getters.isAvatarLoaded),
      list_types_accessories,
      selectedType,
      changeSelectedType,
      selectedAccessory,
      accessoryList,
      changeSelectedAccessory,
      ownAccessory,
      wearAccessory,
      waiting,
      conflictSlots,
    };
  },
  components: {
    RoomConnexion,
    SlotComponent,
    LoadingAvatar,
    Avatar,
  },
});
</script>
