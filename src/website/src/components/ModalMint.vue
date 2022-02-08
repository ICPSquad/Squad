<template>
  <div class="fixed top-0 bottom-0 left-0 right-0 flex flex-col items-center justify-center bg-opacity-30 bg-black">
    <div class="modal bg-white shadow-xl rounded-xl flex flex-col md:w-1/3 w-2/3">
      <header class="border-gray-600 border-b-4 flex flex-row text-5xl font-bold text-gray-800 items-center pl-8 justify-between">
        <h3 class="text-center text-2xl font-bold text-gray-800">{{ name }}</h3>
        <button @click="close" class="bg-pink-600 p-2 m-2 rounded-xl">X</button>
      </header>
      <!-- Connexion -->
      <div v-if="!connected" class="px-24 py-12">
        <accessories-connexion></accessories-connexion>
      </div>
      <!-- Message -->
      <div v-else class="flex flex-col text-center font-bold text-xl text-gray-800 px-8 py-4">
        <div>
          <span style="white-space: pre" :class="waiting ? 'animate-pulse cursor-wait' : ''">{{ message }}</span>
        </div>
        <div class="mx-auto" v-if="showButton">
          <button class="text-2xl shadow-2xl text-gray-800 bg-pink-600 rounded py-3 px-8 mt-6 max-w-2xl mb-6" @click="mint" :class="waiting ? '' : 'cursor-pointer'">Confirm</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script lang="ts">
import { Recipe } from "@/declarations/accessories/accessories.did";
import { defineComponent, ref, computed } from "vue";
import { useStore } from "vuex";
import { getTokensFromInventory } from "../utils/recipe";
import AccessoriesConnexion from "./Connexion/AccessoriesConnexion.vue";

export default defineComponent({
  components: { AccessoriesConnexion },
  emits: ["close"],
  props: {
    name: {
      type: String,
      required: true,
    },
    recipe: {
      type: Array,
      required: true,
    },
  },
  setup(props, context) {
    const store = useStore();
    const message = ref<string>("You're about to mint " + props.name + ".\nIt will burn the corresponding materials from your wallet.\n ⚠️This action is irreversible.\nAre you sure?");
    const waiting = ref<boolean>(false);
    const showButton = ref<boolean>(true);

    const close = () => {
      context.emit("close");
    };

    const mint = async () => {
      message.value = "Checking your inventory...";
      waiting.value = true;

      let inventory = await store.getters.getAuthenticatedActor_material.getInventory();
      console.log("inventory", inventory);
      let tokens = getTokensFromInventory(props.recipe as Recipe, inventory);
      console.log();
      if (!tokens || tokens?.length == 0) {
        message.value = "You don't own the materials to mint this accessory.\nPlease check your inventory. 😕";
        waiting.value = false;
        showButton.value = false;
        return;
      }
    };

    return { close, message, connected: computed(() => store.getters.isInventoryConnected), waiting, mint, showButton };
  },
});
</script>
