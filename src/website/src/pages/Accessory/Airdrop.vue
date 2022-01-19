<template>
  <div class="flex flex-col">
    <airdrop-connexion v-if="!connected"></airdrop-connexion>
    <div
      class="flex flex-col justify-center items-center flex-1"
      v-else-if="loading"
    >
      <h2
        class="
          text-center
          2xl:text-5xl
          lg:text-4xl
          md:text-3xl
          text-2xl
          font-bold
          text-gray-800
          animate-pulse
        "
      >
        {{ loading_message }}
      </h2>
    </div>
    <div
      class="flex flex-col justify-center items-center flex-1"
      v-else-if="error"
    >
      <h2
        class="
          text-center
          2xl:text-5xl
          lg:text-4xl
          md:text-3xl
          text-2xl
          font-bold
          text-gray-800
        "
      >
        {{ error_message }}
      </h2>
      <router-link to="/">
        <button
          class="
            lg:text-3xl
            md:text-2xl
            text-xl
            shadow-2xl
            font-marker
            text-white
            bg-pink-600
            rounded
            py-6
            px-8
            mt-8
            cursor-pointer
          "
        >
          Home 🏠
        </button>
      </router-link>
    </div>
    <div
      v-else-if="airdropObject != undefined"
      class="flex flex-col justify-around flex-1 items-center"
    >
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
        "
      >
        Congratulations !
      </h2>
      <h3
        class="
          text-center
          2xl:text-5xl
          lg:text-4xl
          md:text-3xl
          text-2xl
          font-bold
          text-gray-800
        "
      >
        You have received the following reward :
      </h3>

      <reward-component :airdrop_object="airdropObject"></reward-component>
      <router-link to="/">
        <button
          class="
            lg:text-3xl
            md:text-2xl
            text-xl
            shadow-2xl
            font-marker
            text-white
            bg-pink-600
            rounded
            py-6
            px-8
            mt-8
            cursor-pointer
          "
        >
          Home 🏠
        </button>
      </router-link>
    </div>
    <div class="flex flex-col justify-around flex-1 items-center" v-else>
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
        "
      >
        Thank you for being an early supporter !
      </h2>
      <h3
        class="
          text-center
          2xl:text-5xl
          lg:text-4xl
          md:text-3xl
          text-2xl
          font-bold
          text-gray-800
        "
      >
        Your rank during the preorder was : {{ rank }}.
        <br />
        To receive your reward click on the button.
      </h3>
      <button
        class="
          lg:text-3xl
          md:text-2xl
          text-xl
          shadow-2xl
          font-marker
          text-white
          bg-pink-600
          rounded
          py-6
          px-8
          mt-8
          cursor-pointer
        "
        @click="receiveAirdrop"
      >
        Receive 🎁
      </button>
    </div>
  </div>
</template>

<script lang="ts">
import { defineComponent, computed, ref, onMounted, watch } from "vue";
import { useStore } from "vuex";
import { AirdropObject } from "declarations/event/event.did.d";
import RewardComponent from "./Reward.vue";
import AirdropConnexion from "../../components/Connexion/AirdropConnexion.vue";

export default defineComponent({
  setup() {
    const store = useStore();
    const loading = ref(false);
    const error = ref(false);
    const loading_message = ref("Loading your infos...");
    const error_message = ref("An error occured, please try again.");
    const rank = ref<number>();
    const connected = computed(() => store.getters.isAirdropConnected);

    const airdropObject = ref<AirdropObject>();

    const getRank = async () => {
      if (!store.getters.getAuthenticatedActor_hub) {
        return;
      }
      loading.value = true;
      const actor = store.getters.getAuthenticatedActor_hub;
      const principal = store.getters.getPrincipal;
      const result = await actor.getRank(principal);

      if (result.length === 0) {
        error.value = true;
        loading.value = false;
        error_message.value =
          "Looks like you were not part of the preorder. 😬";
        return;
      }
      rank.value = Number(result[0]);
      loading.value = false;
      return;
    };

    const receiveAirdrop = async () => {
      loading.value = true;
      loading_message.value = "Selecting your reward... 🎲";
      const actor = store.getters.getAuthenticatedActor_hub;
      const result = await actor.airdrop();
      if ("err" in result) {
        error.value = true;
        loading.value = false;
        error_message.value = result.err;
        return;
      }
      airdropObject.value = result.ok;

      loading.value = false;
    };

    onMounted(() => {
      getRank();
    });
    watch(connected, (value) => {
      if (connected) {
        getRank();
      }
    });

    return {
      connected,
      rank,
      loading,
      loading_message,
      error,
      error_message,
      receiveAirdrop,
      airdropObject,
    };
  },
  components: {
    RewardComponent,
    AirdropConnexion,
  },
});
</script>
