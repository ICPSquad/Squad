<template>
  <div class="flex flex-col flex-1 w-full bg-gradient-to-l from-gray-600 via-gray-900 to-black text-white justify-around">
    <!-- Invoice -->
    <div class="flex flex-col w-full items-center gap-y-4">
      <h2 class="text-5xl font-bold mb-8">Invoice 💸</h2>
    </div>
    <div class="flex flex-col w-full items-center gap-y-4">
      <h2 class="text-3xl">Id : {{ Number(invoice.id) }}</h2>
      <h2 class="text-3xl">Account : {{ invoice.account }}</h2>
      <h2 class="text-3xl">Amount : {{ invoice.amount }} ICP</h2>
      <h2 class="text-3xl">Expiration date : {{ new Date(Number(invoice.expiration) / 1000000).toLocaleString() }}</h2>
    </div>

    <!--  Pay -->
    <div class="flex flex-col items-center justify-center">
      <button class="lg:text-3xl md:text-2xl text-xl shadow-2xl font-marker text-white bg-pink-600 rounded py-6 px-14 mt-8 cursor-pointer" @click="pay" :class="loading ? 'animate-pulse' : ''">
        {{ message }}
      </button>
    </div>
    <!--  Help  -->
  </div>
</template>

<script lang="ts">
import { defineComponent, ref } from "vue";
import { useStore } from "vuex";

export default defineComponent({
  props: {
    invoice: {
      type: Object,
      required: true,
    },
  },
  emits: ["success"],
  setup(props, context) {
    const store = useStore();
    const message = ref<string>("Pay");
    const loading = ref<boolean>(false);

    const pay = async () => {
      if (loading.value) {
        return;
      }
      if (!confirm("You are about to pay 1 ICP from your wallet, are you sure?")) {
        return;
      }
      loading.value = true;
      message.value = "Waiting...";
      const wallet = store.getters.getWallet;
      console.log("Wallet: ", wallet);
      if (wallet === "Plug") {
        //@ts-ignore
        try {
          //@ts-ignore
          await window.ic.plug.requestTransfer({
            to: props.invoice.account,
            amount: Number(props.invoice.amount) * 100000000,
            memo: [],
          });
          message.value = "Verification...";
          verify();
        } catch (e) {
          loading.value = false;
          message.value = "Pay";
          throw new Error("Error during payment");
        }
      } else if (wallet === "Stoic") {
        const ledgerActor = store.getters.getAuthenticatedActor_ledger;
        const send_args = {
          to: props.invoice.account,
          fee: 10000,
          amount: { e8s: BigInt(props.invoice.amount * 100000000), from_subbacount: [], created_at_time: [] },
        };
        try {
          await ledgerActor.send_dfx(send_args);
          message.value = "Verification...";
          verify();
        } catch (e) {
          loading.value = false;
          message.value = "Pay";
          throw new Error("Error during payment");
        }
      } else {
        throw new Error("Unknown wallet");
      }
    };

    const verify = async () => {
      const actorHub = store.getters.getAuthenticatedActor_hub;
      const result = await actorHub.confirm_new();
      if (result.hasOwnProperty("err")) {
        loading.value = false;
        message.value = "Pay";
        alert(result.err);
      } else {
        loading.value = false;
        context.emit("success");
      }
    };
    return {
      pay,
      message,
      loading,
    };
  },
});
</script>
