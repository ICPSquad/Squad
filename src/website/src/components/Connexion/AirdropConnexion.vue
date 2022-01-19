<template>
  <div class="flex flex-col justify-around items-center flex-1">
    <div>
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
        Please login 👤
      </h2>
    </div>

    <div class="flex flex-row justify-around w-full">
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
</template>

<script lang="ts">
import { defineComponent, ref } from "vue";
import { useStore } from "vuex";
import {
  idlFactory,
  idlFactory as idlFactory_hub,
} from "declarations/event/index";

//@ts-ignore
import { StoicIdentity } from "ic-stoic-identity";
import { Actor, HttpAgent } from "@dfinity/agent";

export default defineComponent({
  setup() {
    const canister_hub_id = "p4y2d-yyaaa-aaaaj-qaixa-cai";

    const host = "https://mainnet.dfinity.network";
    const whitelist = [canister_hub_id];

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
      const actor_hub = await window.ic.plug.createActor({
        canisterId: canister_hub_id,
        interfaceFactory: idlFactory_hub,
      });
      let principal = await (window as any).ic?.plug?.agent.getPrincipal();

      store.commit("setAuthenticatedActor_hub", actor_hub);
      store.commit("setPrincipal", principal);
      store.commit("setWallet", "plug");
    };

    const stoicConnection = async () => {
      store.commit("setWallet", "stoic");
      let identity = await StoicIdentity.load();
      if (identity !== false) {
      } else {
        identity = await StoicIdentity.connect();
      }
      let myAgent = new HttpAgent({ identity });

      const actor_hub = Actor.createActor(idlFactory_hub, {
        canisterId: canister_hub_id,
        agent: myAgent,
      });
      let principal = identity.getPrincipal();

      store.commit("setAuthenticatedActor_hub", actor_hub);
      store.commit("setPrincipal", principal);
      store.commit("setWallet", "stoic");
    };

    return {
      plugConnection,
      stoicConnection,
    };
  },
});
</script>
