<template>
  <!-- Show wallet info when connected -->
  <div v-if="connected" class="flex flex-col border-t-2 border-gray-600">
    <h2 class="text-center text-white font-bold text-3xl mt-4">Connected</h2>
    <button class="md:text-2xl shadow-2xl text-gray-800 font-bold bg-pink-600 rounded py-4 px-2 my-4 w-1/2 mx-auto" @click="load">Load</button>
  </div>
  <div class="flex flex-col border-t-2 border-gray-600 mb-4" v-else>
    <h2 class="text-center text-gray-200 text-xl md:text-3xl mt-4 font-bold">Please connect your wallet</h2>
    <div></div>
    <button class="lg:text-3xl md:text-2xl text-xl shadow-2xl font-marker text-gray-800 bg-pink-600 rounded py-6 px-8 mt-8 cursor-pointer w-1/2 mx-auto hidden md:block" @click="plugConnection">Plug</button>
    <button class="lg:text-3xl md:text-2xl text-xl shadow-2xl font-marker text-gray-800 bg-pink-600 rounded py-6 px-8 mt-8 w-1/2 mx-auto cursor-pointer" @click="stoicConnection">Stoic</button>
  </div>
</template>

<script lang="ts">
import { computed, defineComponent } from "vue";
import { useStore } from "vuex";
import { idlFactory } from "declarations/accessories/index";
//@ts-ignore
import { StoicIdentity } from "ic-stoic-identity";
import { Actor, HttpAgent } from "@dfinity/agent";
export default defineComponent({
  emits: ["load", "connexion"],
  setup(props, context) {
    const store = useStore();

    const load = () => {
      context.emit("load");
    };

    const canisterId = "po6n2-uiaaa-aaaaj-qaiua-cai";
    const whitelist = [canisterId];
    const host = "https://mainnet.dfinity.network";

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

      store.commit("setAuthenticatedActor_material", myActor);
      store.dispatch("loadInventory");

      store.commit("setPrincipal", principal);
      store.commit("setWallet", "Plug");

      context.emit("connexion");
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

      store.commit("setAuthenticatedActor_material", myActor);
      store.dispatch("loadInventory");

      store.commit("setPrincipal", principal);
      store.commit("setWallet", "stoic");

      context.emit("connexion");
    };

    return {
      plugConnection,
      stoicConnection,
      connected: computed(() => store.getters.isInventoryConnected),
      principal: computed(() => store.getters.getPrincipal),
      load,
    };
  },
});
</script>
