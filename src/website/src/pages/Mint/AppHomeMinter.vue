<template>
  <div class="flex flex-col justify-around h-full" v-if="!connected">
    <div>
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
        Please connect with the same wallet you used for the registration.
      </h3>
    </div>

    <div class="flex flex-row justify-around">
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
          hidden
          md:block
        "
        @click="plugConnection"
      >
        Plug
      </button>
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
        @click="stoicConnection"
      >
        Stoic
      </button>
    </div>
  </div>
  <acknowledgment
    v-else-if="connected && authorized"
    class="flex-1"
  ></acknowledgment>

  <div class="flex flex-col justify-center items-center flex-1" v-else>
    <h3
      class="
        w-2/3
        md:w-1/2
        mx-auto
        text-center
        lg:text-4xl
        md:text-2xl
        text-xl
        font-bold
        mt-16
        text-gray-800
      "
      :class="waiting ? 'animate-pulse' : ''"
    >
      {{ message }}
    </h3>
    <router-link to="/">
      <button
        v-if="!waiting && showHomeButton"
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
    <router-link to="/">
      <button
        v-if="!waiting && showJoinButton"
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
</template>

<script lang="ts">
import { defineComponent, ref } from "vue";
import { useStore } from "vuex";
import { idlFactory } from "declarations/event/index";
//@ts-ignore
import { StoicIdentity } from "ic-stoic-identity";
import { Actor, HttpAgent } from "@dfinity/agent";

import Acknowledgment from "./Acknowledgment.vue";

export default defineComponent({
  setup() {
    const connected = ref(false);
    const authorized = ref(false);
    const waiting = ref(false);

    //To show a different action button based on the error message
    const showHomeButton = ref(true);
    const showJoinButton = ref(false);

    const message = ref("Checking your identity. 👀");
    const canisterId = "p4y2d-yyaaa-aaaaj-qaixa-cai";
    const host = "https://mainnet.dfinity.network";
    const whitelist = [canisterId];

    const store = useStore();

    const plugConnection = async () => {
      const result = await (window as any).ic?.plug?.requestConnect({
        whitelist,
        host,
      });
      if (!result) {
        return;
      }
      //@ts-ignore
      const myActor = await window.ic.plug.createActor({
        canisterId,
        interfaceFactory: idlFactory,
      });
      let principal = await (window as any).ic?.plug?.agent.getPrincipal();

      store.commit("setAuthenticatedActor_hub", myActor);
      store.commit("setPrincipal", principal);
      store.commit("setWallet", "plug");
      connected.value = true;
      verifUser();
    };

    const stoicConnection = async () => {
      store.commit("setWallet", "stoic");
      let identity = await StoicIdentity.load();
      if (identity !== false) {
      } else {
        identity = await StoicIdentity.connect();
      }
      let principal = identity.getPrincipal();
      let myAgent = new HttpAgent({ identity });
      const myActor = await Actor.createActor(idlFactory, {
        canisterId: canisterId,
        agent: myAgent,
      });

      store.commit("setAuthenticatedActor_hub", myActor);
      store.commit("setPrincipal", principal);
      store.commit("setWallet", "stoic");
      connected.value = true;
      verifUser();
    };

    const verifUser = async () => {
      waiting.value = true;
      let result =
        await store.getters.getAuthenticatedActor_hub.isUserAuthorized();
      console.log(result);
      if (result.hasOwnProperty("ok")) {
        waiting.value = false;
        authorized.value = true;
        message.value =
          "Welcome! Thank you for giving your support so early ❤️ ";
      } else {
        waiting.value = false;
        if (result.err == "You haven't registered.") {
          message.value = "You haven't registered yet. Please register first.";
          showJoinButton.value = true;
          showHomeButton.value = false;
        } else if (result.err == "You have already minted your avatar.") {
          message.value = "You have already minted your avatar.";
        }
      }
    };

    return {
      plugConnection,
      stoicConnection,
      connected,
      message,
      authorized,
      waiting,
      showJoinButton,
      showHomeButton,
    };
  },
  components: {
    Acknowledgment,
  },
});
</script>
