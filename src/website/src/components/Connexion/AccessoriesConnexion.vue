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

      store.commit("setWallet", "Plug");

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
      try {
        StoicIdentity.load().then(async (identity: any) => {
          if (identity !== false) {
            //ID is a already connected wallet!
          } else {
            //No existing connection, lets make one!
            identity = await StoicIdentity.connect();
          }
          try {
            await identity.sign("a");
          } catch (e) {
            alert("Error logging in with stoic, please ensure cookies are enabled");
            return;
          }
          //Lets display the connected principal!
          console.log(identity.getPrincipal().toText());
          let principal = identity.getPrincipal();
          store.commit("setWallet", "Stoic");
          store.commit("setPrincipal", principal);

          //Create an actor canister
          const actor = Actor.createActor(idlFactory, {
            agent: new HttpAgent({
              identity,
            }),
            canisterId: canister_accessories_id,
          });
          store.commit("setAuthenticatedActor_material", actor);
          store.dispatch("loadInventory");
        });
      } catch (e) {
        alert(e);
        return;
      }
    };

    return {
      plugConnection,
      stoicConnection,
    };
  },
});
</script>
