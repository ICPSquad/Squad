<template>
  <div class="flex flex-col justify-center mx-auto items-center">
    <div v-if="loading">
      <h2
        class="
          text-center
          lg:text-4xl
          md:text-3xl
          text-2xl
          font-bold
          text-gray-800
          md:mt-16
          mt-8
          animate-pulse
        "
      >
        Your avatar is being generated.
      </h2>
      <h3
        class="
          text-center text-gray-800
          font-bold
          md:text-2xl
          rounded
          py-3
          px-4
          md:px-8
          mt-8
        "
      >
        It will take a few seconds.
      </h3>
      <loading></loading>
    </div>

    <div v-else-if="!loading && !received" class="flex flex-col items-center">
      <button
        @click="sendRequest"
        v-if="!received"
        class="
          font-bold
          text-base text-gray-800
          md:text-2xl
          bg-pink-600
          shadow-2xl
          rounded
          py-3
          mx-auto
          px-4
          md:px-8 md:mt-16
          mt-8
          cursor-pointer
        "
      >
        Mint 🚀
      </button>
      <warning></warning>
    </div>
    <div v-else-if="!loading && received && svg_received">
      <avatar-minted :svg="svg_received"></avatar-minted>
    </div>
  </div>
</template>

<script lang="ts">
import { defineComponent, ref } from "vue";
import { useStore } from "vuex";
import { createMintRequest } from "../../types/mint";
import { MintRequest } from "declarations/event/event.did.d";

import Warning from "./WarningMint.vue";
import Loading from "../../animations/Loading.vue";
import AvatarMinted from "./AvatarMinted.vue";

export default defineComponent({
  emits: ["mint"],
  setup(_, context) {
    const loading = ref(false);
    const received = ref(false);
    const message = ref("When you are ready, click on the button.");
    const url = ref("");
    const store = useStore();
    const svg_received = ref<string>("");

    const verifAvatar = () => {
      const avatar = store.getters.getAvatar;
      if (avatar.Profile == null) {
        alert("You need to choose a profile before minting.");
        return false;
      }
      if (avatar.Eyes == null) {
        alert("You need to choose eyes before minting.");
        return false;
      }
      if (avatar.Mouth == null) {
        alert("You need to choose a mouth before minting.");
        return false;
      }
      if (avatar.Nose == null) {
        alert("You need to choose a nose before minting.");
        return false;
      }
      return true;
    };

    const sendRequest = async () => {
      context.emit("mint");
      if (!verifAvatar()) return;
      if (
        confirm(
          "\n Are you sure you want to mint this avatar? \n This is the last confirmation."
        )
      ) {
        if (loading.value) return;
        loading.value = true;
        message.value =
          "Please wait, your avatar is being generated, it takes around 10 seconds...";
        let request: MintRequest | null = createMintRequest();
        if (request == null) {
          message.value = "Something went wrong, please try again later.";
          loading.value = false;
          return;
        } else {
          let result =
            await store.getters.getAuthenticatedActor_hub.mintRequest(request);
          loading.value = false;
          received.value = true;
          if ("ok" in result) {
            svg_received.value = result.ok.svg;
          } else {
            alert(JSON.stringify(result.err));
          }
        }
      }
    };

    return {
      sendRequest,
      loading,
      received,
      message,
      url,
      svg_received,
    };
  },
  components: {
    Warning,
    Loading,
    AvatarMinted,
  },
});
</script>
