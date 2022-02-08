<template>
  <div class="flex flex-col justify-around items-center flex-1 w-full">
    <div>
      <h2 class="text-center 2xl:text-5xl lg:text-4xl md:text-3xl text-2xl font-bold text-gray-800">Please login 👤</h2>
    </div>

    <div class="flex flex-row justify-around w-full">
      <button class="lg:text-3xl md:text-2xl text-xl shadow-2xl font-marker text-white bg-pink-600 rounded py-6 px-8 mt-8 mx-6 cursor-pointer" @click="plugConnection">Plug</button>
      <button class="lg:text-3xl md:text-2xl text-xl shadow-2xl font-marker text-white bg-pink-600 rounded py-6 px-8 mt-8 mx-6 cursor-pointer" @click="stoicConnection">Stoic</button>
    </div>
  </div>
</template>

<script lang="ts">
import { defineComponent } from "vue";
import { useStore } from "vuex";
import { idlFactory } from "declarations/accessories/index";

//@ts-ignore
import { StoicIdentity } from "ic-stoic-identity";
import { Actor, HttpAgent } from "@dfinity/agent";

export default defineComponent({
  setup() {
    const canister_accessories_id = "po6n2-uiaaa-aaaaj-qaiua-cai";

    const host = "https://mainnet.dfinity.network";
    const whitelist = [canister_accessories_id];

    const store = useStore();

    const plugConnection = async () => {
      const result = await (window as any).ic?.plug?.requestConnect({
        whitelist,
        host,
      });
      if (!result) {
        return;
      }

      store.commit("setWallet", "plug");

      let principal = await (window as any).ic?.plug?.agent.getPrincipal();
      store.commit("setPrincipal", principal);

      //@ts-ignore
      const actor_material = await window.ic.plug.createActor({
        canisterId: canister_accessories_id,
        interfaceFactory: idlFactory,
      });
      store.commit("setAuthenticatedActor_material", actor_material);
      store.dispatch("loadInventory");
    };

    const stoicConnection = async () => {
      store.commit("setWallet", "stoic");
      let identity = await StoicIdentity.load();
      if (identity !== false) {
      } else {
        identity = await StoicIdentity.connect();
      }
      let principal = identity.getPrincipal();
      store.commit("setPrincipal", principal);

      let myAgent = new HttpAgent({ identity });

      //@ts-ignore
      const actor_material = Actor.createCanister(idlFactory_material, {
        canisterId: canister_accessories_id,
        agent: myAgent,
      });
      store.commit("setAuthenticatedActor_material", actor_material);
      store.dispatch("loadInventory");
    };

    return {
      plugConnection,
      stoicConnection,
    };
  },
});
</script>
