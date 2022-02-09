<template>
  <div class="fixed top-0 bottom-0 left-0 right-0 flex flex-col items-center justify-center bg-opacity-30 bg-black">
    <div class="modal bg-white shadow-xl rounded-xl flex flex-col w-2/3">
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
        <div class="w-full">
          <span style="white-space: pre" :class="waiting ? 'animate-pulse cursor-wait' : ''">{{ message }}</span>
        </div>
        <div class="mx-auto" v-if="showButtonMint">
          <button class="text-2xl shadow-2xl text-black font-bold bg-pink-600 rounded py-3 px-8 mt-6 max-w-2xl mb-6" @click="checkInventory" :class="waiting ? '' : 'cursor-pointer'">Mint</button>
        </div>
        <div class="mx-auto" v-if="showButtonFee">
          <button class="text-2xl shadow-2xl text-black font-bold bg-pink-600 rounded py-3 px-8 mt-6 max-w-2xl mb-6" @click="payFee" :class="waiting ? '' : 'cursor-pointer'">Confirm</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script lang="ts">
import { Recipe, SubAccount, Result_6 } from "@/declarations/accessories/accessories.did";
import { defineComponent, ref, computed } from "vue";
import { useStore } from "vuex";
//@ts-ignore
import { StoicIdentity } from "ic-stoic-identity";
import { getTokensFromInventory } from "../utils/recipe";
import { getRandomSubaccount, pay_plug, pay_stoic } from "../utils/payment";
import { createLedgerCanister } from "../utils/ledger";
import { HttpAgent } from "@dfinity/agent";
import AccessoriesConnexion from "./Connexion/AccessoriesConnexion.vue";
import ProgressBar from "../components/UI/ProgressBar.vue";

export default defineComponent({
  components: { AccessoriesConnexion, ProgressBar },
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
    const showButtonMint = ref<boolean>(true);
    const showButtonFee = ref<boolean>(false);

    //Transaction & mint
    const tokens = ref<Array<string>>([]);
    const subaccount = ref<SubAccount>();

    const close = () => {
      context.emit("close");
    };

    const checkInventory = async () => {
      message.value = "Checking your inventory...";
      waiting.value = true;
      showButtonMint.value = false;
      let inventory = await store.getters.getAuthenticatedActor_material.getInventory();
      let tokens_opt = getTokensFromInventory(props.recipe as Recipe, inventory);
      if (!tokens_opt || tokens_opt?.length == 0) {
        message.value = "You don't own the materials to mint this accessory. 😕";
        waiting.value = false;
        showButtonMint.value = false;
        return;
      } else {
        tokens.value = tokens_opt as Array<string>;
        message.value = "You own the materials to mint this accessory. 😁 \nBefore proceding you need to pay the minting fee (0.1 ICP).\nAre you sure?";
        waiting.value = false;
        showButtonFee.value = true;
        console.log("inventory checked and tokens : ", tokens.value);
      }
    };

    async function mint(): Promise<void> {
      message.value = "Minting...";
      let actor_accessories = store.getters.getAuthenticatedActor_material;
      let result = await actor_accessories.createAccessory(props.name, tokens.value, subaccount.value, []);
      console.log("result : ", result);
    }

    const payFee = async () => {
      showButtonFee.value = false;
      message.value = "Paying the fee...";
      waiting.value = true;
      subaccount.value = getRandomSubaccount();
      let wallet = store.getters.getWallet;
      console.log("Wallet is ", wallet);
      if (wallet === "plug") {
        let transaction = await pay_plug(subaccount.value, BigInt(100), 10000);
        if (transaction.height != 0) {
          mint();
        }
      }
      if (wallet === "stoic") {
        let ledgerActor;
        // Get the stoic identity
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
            ledgerActor = createLedgerCanister(new HttpAgent({ identity }));
          });
        } catch (e) {
          alert(e);
          return;
        }
        await pay_stoic(ledgerActor, subaccount.value, BigInt(100), 10000);
      }
    };

    return { close, message, connected: computed(() => store.getters.isInventoryConnected), waiting, checkInventory, showButtonMint, showButtonFee, payFee };
  },
});
</script>
